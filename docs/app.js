/* OneShotBid browser demo – mirrors the real app's rules:
   a bid must be higher than the start price and the current highest bid, auctions end at their end time,
   the highest bidder wins and gets a notification, then can "pay". All state lives in localStorage. */
(function () {
  'use strict';
  var KEY = 'osb.demo.v1';
  var $ = function (s) { return document.querySelector(s); };
  var state, tab = 'auctions', openId = null, tick = null;

  function esc(t) { return String(t).replace(/[&<>"']/g, function (c) { return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]; }); }
  function rm(n) { return 'RM ' + Number(n).toLocaleString('en-MY', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }
  var H = 3600e3;

  function seed() {
    var now = Date.now();
    function item(id, emoji, bg, name, desc, ed, start, hrs) {
      return { id: id, emoji: emoji, bg: bg, name: name, desc: desc, edition: ed, start: start, end: now + hrs * H, bids: [], status: 'active', paid: false, seller: 'OneShotBid' };
    }
    return {
      user: 'Guest' + Math.floor(100 + Math.random() * 900), nextId: 7, notes: [],
      items: [
        item(1, '⌚', 'linear-gradient(135deg,#3a1c71,#d76d77)', 'Vintage Chronograph', 'Hand-wound steel watch, serviced and boxed.', 1, 250, 5),
        item(2, '🎸', 'linear-gradient(135deg,#134e5e,#71b280)', 'Signed Acoustic Guitar', 'Limited run, signed by the maker.', 3, 900, 26),
        item(3, '🖼️', 'linear-gradient(135deg,#614385,#516395)', 'Sunset Print (Framed)', 'Large framed photographic print.', 10, 120, 2.5),
        item(4, '🎮', 'linear-gradient(135deg,#232526,#e44d26)', 'Retro Console Bundle', 'Console, two controllers and 8 games.', 1, 300, 50),
        item(5, '📷', 'linear-gradient(135deg,#0f2027,#2c5364)', 'Film Camera Kit', '35mm body, 50mm lens and case.', 1, 180, 0.02)
      ]
    };
  }
  function load() { try { var s = JSON.parse(localStorage.getItem(KEY)); if (s && s.items) return s; } catch (e) {} return seed(); }
  function save() { try { localStorage.setItem(KEY, JSON.stringify(state)); } catch (e) {} }
  state = load();

  function top(it) { return it.bids.length ? it.bids[0] : null; }          // newest-highest first
  function current(it) { var t = top(it); return t ? t.amount : it.start; }
  function note(msg) { state.notes.unshift({ msg: msg, at: Date.now(), read: false }); }

  /* Mirrors AuctionEndCheckerServlet: end finished auctions, notify the winner. */
  function settle() {
    var changed = false;
    state.items.forEach(function (it) {
      if (it.status === 'active' && it.end <= Date.now()) {
        it.status = 'ended'; changed = true;
        var t = top(it);
        if (t && t.user === state.user) note('🎉 You won "' + it.name + '" with ' + rm(t.amount) + '. Go to Won items to pay.');
      }
    });
    if (changed) save();
    return changed;
  }
  function left(ms) {
    if (ms <= 0) return 'Ended';
    var s = Math.floor(ms / 1000), h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60); s = s % 60;
    return (h ? h + 'h ' : '') + (m || h ? m + 'm ' : '') + s + 's';
  }

  function nav() {
    var unread = state.notes.filter(function (n) { return !n.read; }).length;
    var tabs = [['auctions', 'Auctions'], ['mybids', 'My bids'], ['won', 'Won items'], ['sell', '+ New auction'], ['notes', 'Notifications' + (unread ? ' (' + unread + ')' : '')]];
    $('#nav').innerHTML = tabs.map(function (t) { return '<button data-t="' + t[0] + '" class="' + (tab === t[0] && !openId ? 'on' : '') + '">' + t[1] + '</button>'; }).join('');
  }

  function cardHtml(it, i) {
    var live = it.status === 'active';
    return '<div class="card" data-open="' + it.id + '" style="animation-delay:' + (i * 70) + 'ms"><div class="pic" style="background:' + it.bg + '">' + it.emoji + '</div><div class="body"><h3>' + esc(it.name) + '</h3><div class="price">' + rm(current(it)) + '</div><div class="meta"><span class="tag ' + (live ? 'live' : 'end') + '">' + (live ? 'LIVE' : 'ENDED') + '</span><span class="timer' + (live && it.end - Date.now() < 3e5 ? ' low' : '') + '" data-end="' + it.end + '">' + (live ? left(it.end - Date.now()) : 'Ended') + '</span></div></div></div>';
  }

  function viewAuctions() {
    var list = state.items.slice().sort(function (a, b) { return (b.status === 'active') - (a.status === 'active') || a.end - b.end; });
    return '<h1>Live auctions</h1><p class="sub">One shot to win: outbid everyone before the clock hits zero.</p><div class="grid">' + (list.map(cardHtml).join('') || '<div class="empty">No auctions yet.</div>') + '</div>';
  }
  function viewMy() {
    var mine = state.items.filter(function (it) { return it.bids.some(function (b) { return b.user === state.user; }); });
    return '<h1>My bids</h1><p class="sub">Auctions you have bid on, as ' + esc(state.user) + '.</p>' + (mine.length ? '<div class="grid">' + mine.map(cardHtml).join('') + '</div>' : '<div class="empty">You have not placed any bids yet.</div>');
  }
  function viewWon() {
    var won = state.items.filter(function (it) { var t = top(it); return it.status === 'ended' && t && t.user === state.user; });
    return '<h1>Won items</h1><p class="sub">Items you won – complete the (demo) payment.</p>' + (won.length ? '<div class="grid">' + won.map(function (it, i) {
      return '<div class="card" style="cursor:default;animation-delay:' + i * 70 + 'ms"><div class="pic" style="background:' + it.bg + '">' + it.emoji + '</div><div class="body"><h3>' + esc(it.name) + '</h3><div class="price">' + rm(current(it)) + '</div><div class="meta">' + (it.paid ? '<span class="tag live">PAID</span>' : '<button class="btn gold" data-pay="' + it.id + '">Pay now</button>') + '</div></div></div>';
    }).join('') + '</div>' : '<div class="empty">Nothing won yet. Place a bid and wait for it to end!</div>');
  }
  function viewSell() {
    var d = new Date(Date.now() + 30 * 60e3);
    return '<h1>Create an auction</h1><p class="sub">Add your own item to this demo.</p><div class="panel"><form id="sellForm"><label>Item name</label><input name="name" required maxlength="60"><label>Description</label><textarea name="desc" rows="3" maxlength="300"></textarea><div class="row"><div style="flex:1"><label>Starting price (RM)</label><input name="start" type="number" min="1" step="0.01" required value="50"></div><div style="flex:1"><label>Duration (minutes)</label><input name="mins" type="number" min="1" max="10080" required value="30"></div></div><div id="sellMsg"></div><p><button class="btn gold" type="submit">Start auction</button></p></form></div>';
  }
  function viewNotes() {
    state.notes.forEach(function (n) { n.read = true; }); save();
    return '<h1>Notifications</h1><p class="sub">Updates like “you won” or “you were outbid”.</p>' + (state.notes.length ? state.notes.map(function (n) { return '<div class="note">' + esc(n.msg) + '<div class="meta"><span>' + new Date(n.at).toLocaleString() + '</span></div></div>'; }).join('') : '<div class="empty">No notifications.</div>');
  }
  function viewItem(it) {
    var live = it.status === 'active', t = top(it), cur = current(it), min = (cur + (t ? 0.01 : 0)).toFixed(2);
    return '<p><button class="btn ghost" id="back">← Back</button></p><div class="two"><div class="panel" style="padding:0;overflow:hidden"><div class="big" style="background:' + it.bg + '">' + it.emoji + '</div><div style="padding:18px"><h1 style="margin:0">' + esc(it.name) + '</h1><p class="sub">' + esc(it.desc || 'No description.') + '</p><div class="meta"><span>Edition count: ' + it.edition + '</span><span>Seller: ' + esc(it.seller) + '</span></div></div></div>' +
      '<div class="panel"><div class="meta"><span class="tag ' + (live ? 'live' : 'end') + '">' + (live ? 'LIVE' : 'ENDED') + '</span><span class="timer" id="itemTimer" data-end="' + it.end + '">' + left(it.end - Date.now()) + '</span></div><p class="sub" style="margin:14px 0 0">' + (t ? 'Highest bid' : 'Starting price') + '</p><div class="price" style="font-size:36px" id="curPrice">' + rm(cur) + '</div><p class="sub">' + (t ? 'by ' + esc(t.user) : 'No bids yet') + '</p>' +
      (live ? '<form id="bidForm" novalidate><label>Your bid (RM)</label><div class="row"><input name="amt" type="number" step="0.01" min="' + min + '" placeholder="more than ' + cur.toFixed(2) + '" style="flex:1" required><button class="btn gold" type="submit">Place bid</button></div></form><div id="bidMsg"></div>' : '<div class="msg ok">Auction ended' + (t ? ' – won by ' + esc(t.user) : ' with no bids') + '.</div>') +
      '<h3 style="margin-top:22px">Bid history</h3>' + (it.bids.length ? '<table><tr><th>Bidder</th><th>Amount</th><th>Time</th></tr>' + it.bids.slice(0, 12).map(function (b, i) { return '<tr' + (i === 0 && b.fresh ? ' class="new"' : '') + '><td>' + esc(b.user) + '</td><td>' + rm(b.amount) + '</td><td>' + new Date(b.at).toLocaleTimeString() + '</td></tr>'; }).join('') + '</table>' : '<div class="empty" style="padding:14px">Be the first to bid.</div>') + '</div></div>';
  }

  function render() {
    settle(); nav();
    var v = $('#view'), it = openId && state.items.filter(function (x) { return x.id === openId; })[0];
    v.innerHTML = it ? viewItem(it) : ({ auctions: viewAuctions, mybids: viewMy, won: viewWon, sell: viewSell, notes: viewNotes }[tab] || viewAuctions)();
    state.items.forEach(function (x) { x.bids.forEach(function (b) { delete b.fresh; }); });
  }
  function toast(m) { var d = document.createElement('div'); d.className = 'toast'; d.textContent = m; document.body.appendChild(d); setTimeout(function () { d.remove(); }, 2800); }

  document.addEventListener('click', function (e) {
    var t = e.target.closest('[data-t],[data-open],[data-pay],#back,#reset'); if (!t) return;
    if (t.dataset.t) { tab = t.dataset.t; openId = null; render(); }
    else if (t.dataset.open) { openId = +t.dataset.open; render(); window.scrollTo({ top: 0, behavior: 'smooth' }); }
    else if (t.id === 'back') { openId = null; render(); }
    else if (t.dataset.pay) { var it = state.items.filter(function (x) { return x.id === +t.dataset.pay; })[0]; if (it) { it.paid = true; note('✅ Payment received for "' + it.name + '" (demo – no real money involved).'); save(); toast('Payment completed (demo)'); render(); } }
    else if (t.id === 'reset') { if (confirm('Reset all demo data on this device?')) { var u = state.user; state = seed(); state.user = u; save(); openId = null; tab = 'auctions'; render(); } }
  });

  document.addEventListener('submit', function (e) {
    e.preventDefault();
    var f = e.target;
    if (f.id === 'bidForm') {
      var it = state.items.filter(function (x) { return x.id === openId; })[0], amt = Math.round(parseFloat(f.amt.value) * 100) / 100, box = $('#bidMsg');
      if (!it || it.status !== 'active' || it.end <= Date.now()) { box.innerHTML = '<div class="msg err">This auction has already ended.</div>'; return; }
      if (!isFinite(amt) || amt <= current(it)) { box.innerHTML = '<div class="msg err">Your bid must be higher than ' + rm(current(it)) + '.</div>'; return; }
      var prev = top(it);
      it.bids.unshift({ user: state.user, amount: amt, at: Date.now(), fresh: true });
      if (prev && prev.user !== state.user) note('⚠️ You were outbid on "' + it.name + '".');
      save(); toast('Bid of ' + rm(amt) + ' placed'); render();
    } else if (f.id === 'sellForm') {
      var name = f.name.value.trim(), start = parseFloat(f.start.value), mins = parseInt(f.mins.value, 10);
      if (!name || !(start > 0) || !(mins > 0)) { $('#sellMsg').innerHTML = '<div class="msg err">Please fill in a name, a positive price and a duration.</div>'; return; }
      var bgs = ['linear-gradient(135deg,#42275a,#734b6d)', 'linear-gradient(135deg,#1d976c,#93f9b9)', 'linear-gradient(135deg,#355c7d,#c06c84)'];
      state.items.unshift({ id: state.nextId++, emoji: '📦', bg: bgs[state.nextId % 3], name: name, desc: f.desc.value.trim(), edition: 1, start: start, end: Date.now() + mins * 60e3, bids: [], status: 'active', paid: false, seller: state.user });
      save(); tab = 'auctions'; render(); toast('Auction started');
    }
  });

  var u = $('#user'); u.value = state.user;
  u.addEventListener('change', function () { var v = u.value.trim().slice(0, 20) || state.user; state.user = v; u.value = v; save(); render(); });

  /* Live clocks: update timers each second without re-rendering the page. */
  tick = setInterval(function () {
    var ended = settle();
    document.querySelectorAll('.timer').forEach(function (el) { var ms = +el.dataset.end - Date.now(); el.textContent = left(ms); el.classList.toggle('low', ms > 0 && ms < 3e5); });
    if (ended) render();
  }, 1000);

  render();
})();
