const app=document.getElementById('app');
let sessionUser=null;
const $=s=>document.querySelector(s), esc=s=>String(s??'').replace(/[&<>'"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));
async function api(action,params={},method='GET'){let url=`api/platform?action=${encodeURIComponent(action)}`;let opts={credentials:'same-origin'};if(method==='GET'){url+='&'+new URLSearchParams(params)}else{opts.method='POST';opts.headers={'Content-Type':'application/json'};opts.body=JSON.stringify(params)}let r=await fetch(url,opts);let d=await r.json();if(!r.ok||d.success===false)throw new Error(d.message||'Request failed');return d}
function toast(m){let t=document.createElement('div');t.className='toast';t.textContent=m;document.body.appendChild(t);setTimeout(()=>t.remove(),2500)}
async function session(){let r=await fetch('api/session');let d=await r.json();if(!d.loggedIn){location.href='login.html';return null}sessionUser=d.user;$('#avatar').textContent=(sessionUser.fullName||'M')[0].toUpperCase();return sessionUser}
const titles={home:'Your college life, in one place.',identity:'Your Digital Identity',academics:'Student Portal',career:'Career & Opportunities',community:'Campus Community',sports:'Sports & Cultural Record',analytics:'Your Campus Analytics',campus3d:'3D Campus',directory:'Student Directory',clubs:'Clubs & Communities',events:'Campus Events',yearbook:'Digital Yearbook',messages:'Messages',leaderboard:'Leaderboard',notifications:'Notifications',admin:'Administration'};
function shell(html){app.innerHTML=html;document.querySelectorAll('[data-view]').forEach(x=>x.onclick=()=>show(x.dataset.view));}
async function show(view){document.body.classList.toggle('campus-view',view==='campus3d');document.querySelectorAll('.nav-item').forEach(x=>x.classList.toggle('active',x.dataset.view===view));document.getElementById('pageTitle').textContent=titles[view]||'MIT Socials';app.innerHTML='<div class="loading">Loading…</div>';try{({home:home,identity:identity,academics:academics,career:career,community:community,sports:sports,analytics:analytics,campus3d:campus3d,directory:directory,clubs:clubs,events:events,yearbook:yearbook,messages:messages,leaderboard:leaderboard,notifications:notifications,admin:admin}[view]||home)()}catch(e){app.innerHTML=`<div class="card"><b>Could not load this module.</b><p class="muted">${esc(e.message)}</p></div>`}}
async function home(){let d=await api('dashboard');shell(`<div class="hero"><div><span class="tag">PRIVATE CAMPUS NETWORK</span><h2>Welcome back, ${esc(sessionUser.fullName.split(' ')[0])} 👋</h2><p>${esc(sessionUser.branch)} · ${esc(sessionUser.year)} · Division ${esc(sessionUser.division)}. Your professional, academic, sports and social life—connected.</p></div><div class="hero-actions"><button class="btn btn-primary" data-view="identity">View identity</button><button class="btn btn-ghost" data-view="campus3d">Explore campus</button></div></div><div class="grid stats"><div class="card"><span class="muted">My posts</span><div class="stat-value">${d.stats.posts}</div></div><div class="card"><span class="muted">Clubs joined</span><div class="stat-value">${d.stats.clubs}</div></div><div class="card"><span class="muted">Events registered</span><div class="stat-value">${d.stats.events}</div></div><div class="card"><span class="muted">Leaderboard points</span><div class="stat-value">${d.stats.points}</div></div></div><div class="grid two"><div class="card"><div class="section-head"><h2>Upcoming events</h2><button class="btn btn-ghost" data-view="events">View all</button></div><div class="list">${d.events.map(eventCard).join('')||empty('No upcoming events')}</div></div><div class="card"><div class="section-head"><h2>My campus clubs</h2><button class="btn btn-ghost" data-view="clubs">Explore</button></div><div class="list">${d.clubs.map(clubCard).join('')||empty('Join your first club')}</div></div></div><div class="section-head"><h2>Quick access</h2></div><div class="grid four">${[['📚','Student Portal','academics'],['💼','Career','career'],['🏆','Sports & Cultural','sports'],['💬','Messages','messages']].map(x=>`<button class="card" style="text-align:left;border:0;cursor:pointer" data-view="${x[2]}"><div style="font-size:25px">${x[0]}</div><b>${x[1]}</b><p class="muted">Open module</p></button>`).join('')}</div>`)}
function eventCard(e){let full=e.seats>0&&e.registered>=e.seats;return `<div class="event"><div class="event-icon">📅</div><div style="flex:1"><h3>${esc(e.title)}</h3><span class="tag">${esc(e.type)}</span><p class="muted">${esc(e.venue)} · ${new Date(e.date).toLocaleString()}</p></div><button class="btn ${e.joined?'btn-ghost':'btn-primary'}" onclick="eventAction(${e.id},${!e.joined})">${e.joined?'Registered':full?'Full':'Register'}</button></div>`}
function clubCard(c){return `<div class="club"><div class="club-icon">🤝</div><div style="flex:1"><h3>${esc(c.name)} ${c.verified?'✓':''}</h3><span class="tag">${esc(c.category)}</span><p class="muted">${c.members} members</p></div><button class="btn ${c.joined?'btn-ghost':'btn-primary'}" onclick="clubAction(${c.id},${!c.joined})">${c.joined?'Joined':'Join'}</button></div>`}
function empty(x){return `<div class="empty">${x}</div>`}
async function identity(){let d=await api('profile',{id:sessionUser.id});let p=d.profile;shell(`<div class="profile-cover"><div class="profile-avatar">${esc(p.name[0])}</div></div><div class="card profile-head"><div class="section-head"><div><h2>${esc(p.name)}</h2><p class="muted">${esc(p.branch)} · ${esc(p.year)} · Division ${esc(p.division)} · ${esc(p.studentId)}</p></div><button class="btn btn-primary" data-view="directory">Find classmates</button></div><p>${esc(p.bio||'Add a short bio to introduce yourself.')}</p></div><div class="grid three"><div class="card"><span class="muted">Skills</span><div class="kpi">${d.skills.length}</div></div><div class="card"><span class="muted">Projects</span><div class="kpi">${d.projects.length}</div></div><div class="card"><span class="muted">Achievements</span><div class="kpi">${d.achievements.length}</div></div></div><div class="grid two"><div class="card"><h2>Professional</h2>${d.skills.map(x=>`<p><b>${esc(x.skill_name)}</b> · ${esc(x.proficiency_level)}</p>`).join('')||empty('No skills added yet')}</div><div class="card"><h2>Sports & Cultural</h2>${[...d.sports,...d.cultural].slice(0,6).map(x=>`<p><b>${esc(x.sport||x.category)}</b> · ${esc(x.event)}</p>`).join('')||empty('No records yet')}</div></div>`)}
async function academics(){let d=await api('academics');shell(`<div class="grid three"><div class="card"><span class="muted">Current GPA</span><div class="kpi">${Number(d.gpa).toFixed(2)}</div></div><div class="card"><span class="muted">Courses</span><div class="kpi">${d.courses.length}</div></div><div class="card"><span class="muted">Attendance</span><div class="kpi">${d.attendance.length?Math.round(d.attendance.reduce((a,x)=>a+x.percentage,0)/d.attendance.length):0}%</div></div></div><div class="card"><div class="section-head"><h2>Courses & grades</h2></div><table class="table"><thead><tr><th>Code</th><th>Course</th><th>Credits</th><th>Grade</th><th>Points</th></tr></thead><tbody>${d.courses.map(x=>`<tr><td>${esc(x.code)}</td><td>${esc(x.name)}</td><td>${x.credits}</td><td><b>${esc(x.grade||'-')}</b></td><td>${x.gradePoints||'-'}</td></tr>`).join('')}</tbody></table></div><div class="card"><h2>Attendance</h2>${d.attendance.map(x=>`<p><b>${esc(x.code)}</b> ${esc(x.name)} <span class="muted">— ${x.attended}/${x.total} (${Math.round(x.percentage)}%)</span></p>`).join('')||empty('No attendance records yet')}</div>`)}
async function career(){let d=await api('career');shell(`<div class="grid three"><div class="card"><span class="muted">Skills</span><div class="kpi">${d.skills.length}</div></div><div class="card"><span class="muted">Projects</span><div class="kpi">${d.projects.length}</div></div><div class="card"><span class="muted">Internships</span><div class="kpi">${d.internships.length}</div></div></div><div class="grid two"><div class="card"><h2>Projects</h2>${d.projects.map(x=>`<div class="message"><div class="event-icon">🛠️</div><div><b>${esc(x.title)}</b><p class="muted">${esc(x.description||'')}<br>${esc(x.technologies_used||'')}</p></div></div>`).join('')||empty('No projects yet')}</div><div class="card"><h2>Internships & certificates</h2>${d.internships.map(x=>`<p><b>${esc(x.role_title)}</b> · ${esc(x.company_name)}</p>`).join('')||empty('No internships yet')}<hr><h3>Open opportunities</h3>${d.jobs.map(x=>`<p><b>${esc(x.title)}</b> · ${esc(x.company)} <span class="muted">${esc(x.location||'')}</span></p>`).join('')||empty('No open opportunities')}<hr>${d.certificates.map(x=>`<p>📜 <b>${esc(x.title)}</b> · ${esc(x.issuing_organization)}</p>`).join('')}</div></div>`)}
async function community(){let [c,f]=await Promise.all([api('communities'),api('feed')]);shell(`<div class="hero"><div><span class="tag">COMMUNITY</span><h2>Build your campus network.</h2><p>Join discussions, share projects, follow classmates and keep up with campus life.</p></div><button class="btn btn-primary" onclick="createPost()">+ Create post</button></div><div class="section-head"><h2>Communities</h2></div><div class="grid three">${c.communities.map(x=>`<div class="card"><div class="event-icon">💡</div><h3>${esc(x.name)}</h3><p class="muted">${esc(x.description||'Campus discussion space')}</p><span class="tag">${x.members} members</span><button class="btn ${x.joined?'btn-ghost':'btn-primary'}" style="margin-left:8px" onclick="communityAction(${x.id},${!x.joined})">${x.joined?'Joined':'Join'}</button></div>`).join('')}</div><div class="section-head"><h2>Campus feed</h2></div><div class="list">${f.posts.map(x=>`<div class="card"><b>${esc(x.author)}</b><span class="muted"> · ${new Date(x.createdAt).toLocaleString()}</span><p>${esc(x.caption)}</p><span class="muted">♥ ${x.likes} · 💬 ${x.comments}</span><button class="btn btn-ghost" onclick="likePost(${x.id},${!x.liked})">${x.liked?'Unlike':'Like'}</button><button class="btn btn-ghost" onclick="commentPost(${x.id})">Comment</button></div>`).join('')||empty('No posts yet')}</div>`)}
async function sports(){let d=await api('sports');let total=(d.sports?.length||0)+(d.cultural?.length||0);let medals=(d.sports||[]).filter(x=>x.medal).length;let wins=(d.sports||[]).filter(x=>/win|winner|1st|gold/i.test((x.result||'')+' '+(x.medal||''))).length;let cats=[...new Set((d.cultural||[]).map(x=>x.category).filter(Boolean))];shell(`<div class="hero"><div><span class="tag">SPORTS & CULTURAL</span><h2>Your campus participation, in detail.</h2><p>Keep a clear record of sports, cultural activities, results, awards and participation across your college life.</p></div></div><div class="grid four" style="margin-top:18px"><div class="card"><span class="muted">Total records</span><div class="kpi">${total}</div></div><div class="card"><span class="muted">Sports entries</span><div class="kpi">${d.sports.length}</div></div><div class="card"><span class="muted">Awards / medals</span><div class="kpi">${medals}</div></div><div class="card"><span class="muted">Cultural categories</span><div class="kpi">${cats.length}</div></div></div><div class="grid two" style="margin-top:18px"><div class="card"><div class="section-head"><div><h2>Sports participation</h2><p class="muted">Results, events and medals</p></div></div><div class="list">${d.sports.map(x=>`<div class="message"><div class="event-icon">🏆</div><div style="flex:1"><b>${esc(x.sport)}</b><p class="muted">${esc(x.event)} · ${esc(x.year)} · ${esc(x.result||'Participation')}</p>${x.medal?`<span class="tag">${esc(x.medal)}</span>`:''}</div></div>`).join('')||empty('No sports records yet')}</div></div><div class="card"><div class="section-head"><div><h2>Cultural participation</h2><p class="muted">Activities, events and recognition</p></div></div><div class="list">${d.cultural.map(x=>`<div class="message"><div class="event-icon">🎭</div><div style="flex:1"><b>${esc(x.category)}</b><p class="muted">${esc(x.event)} · ${esc(x.year)} · ${esc(x.result_win||x.award||'Participation')}</p></div></div>`).join('')||empty('No cultural records yet')}</div></div></div><div class="card" style="margin-top:18px"><div class="section-head"><h2>Participation summary</h2></div><p class="muted">${wins?`You have ${wins} sports result${wins===1?'':'s'} marked as a win or top finish.`:'Add results to your sports records to track wins and recognition.'} ${cats.length?`Cultural activity spans ${cats.join(', ')}.`:''}</p></div>`)}
async function analytics(){let [d,s,l]=await Promise.all([api('dashboard'),api('sports'),api('leaderboard',{category:'OVERALL'})]);shell(`<div class="grid four"><div class="card"><span class="muted">Posts</span><div class="kpi">${d.stats.posts}</div></div><div class="card"><span class="muted">Clubs</span><div class="kpi">${d.stats.clubs}</div></div><div class="card"><span class="muted">Events</span><div class="kpi">${d.stats.events}</div></div><div class="card"><span class="muted">Points</span><div class="kpi">${d.stats.points}</div></div></div><div class="grid two"><div class="card"><h2>Participation snapshot</h2><div class="stat-value">${s.sports.length}</div><p class="muted">sports records · ${s.cultural.length} cultural records</p><div style="height:18px;background:#e6efe8;border-radius:99px"><div style="width:${Math.min(100,s.sports.length*12+20)}%;height:100%;background:#31935b;border-radius:99px"></div></div></div><div class="card"><h2>Overall leaderboard</h2>${l.leaders.slice(0,5).map(x=>`<p><b>#${x.rank} ${esc(x.name)}</b><span class="muted"> — ${x.points} points</span></p>`).join('')}</div></div>`)}
async function campus3d(){
  const d=await api('campus');
  const byName=Object.fromEntries((d.locations||[]).map(x=>[String(x.name).toLowerCase(),x]));
  const locations=[
    {key:'Academic Building 1',label:'Academic Building 1',icon:'🏫',kind:'academic',accent:'#f3a12f'},
    {key:'Academic Building 2',label:'Academic Building 2',icon:'🏫',kind:'academic',accent:'#3b8eea'},
    {key:'Academic Building 3',label:'Academic Building 3',icon:'🏫',kind:'academic',accent:'#8b5cf6'},
    {key:'Basketball Court',label:'Basketball Court',icon:'🏀',kind:'court',accent:'#ef5350'},
    {key:'Student Hostel',label:'Hostel',icon:'🛏️',kind:'hostel',accent:'#8b5cf6'},
    {key:'Gazebo',label:'Gazebo',icon:'🌳',kind:'gazebo',accent:'#25a36a'},
    {key:'Main Playground',label:'Main Ground',icon:'🏃',kind:'ground',accent:'#22a06b'},
    {key:'Swimming Pool',label:'Swimming Pool',icon:'🏊',kind:'pool',accent:'#2999e8'}
  ];
  const locationData=locations.map(x=>({
    ...x,
    data:byName[x.key.toLowerCase()]||byName[x.label.toLowerCase()]||{name:x.key,category:x.kind,description:'Campus location.'}
  }));
  shell(`<div class="campus-page">
    <div class="campus-page-head">
      <div><div class="campus-breadcrumb">MIT Socials <span>|</span> Student Life</div><h2>3D Campus</h2><p>Explore the campus and discover key locations</p></div>
      <div class="campus-search"><span>⌕</span><input id="campusSearch" placeholder="Search location…"><button id="campusTheme" type="button">☀</button><button type="button" data-view="notifications">🔔</button><div class="avatar">${esc((sessionUser.fullName||'S')[0])}</div></div>
    </div>
    <div class="campus-layout">
      <div class="campus-map-card">
        <div class="campus-scene" id="campusScene">
          <svg id="campusMap" viewBox="0 0 1000 620" role="img" aria-label="MIT Socials campus map">
            <defs>
              <linearGradient id="campusGrass" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#eaf5df"/><stop offset="1" stop-color="#d5e8c8"/></linearGradient>
              <linearGradient id="roofCream" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fffdf8"/><stop offset="1" stop-color="#e9eee8"/></linearGradient>
              <filter id="softShadow" x="-30%" y="-30%" width="160%" height="180%"><feDropShadow dx="8" dy="12" stdDeviation="9" flood-color="#315a43" flood-opacity=".18"/></filter>
            </defs>
            <rect x="18" y="18" width="964" height="584" rx="34" fill="url(#campusGrass)"/>
            <path class="campus-road" d="M38 265 H955"/>
            <path class="campus-road" d="M515 265 C515 310 492 322 452 347 C423 365 398 384 385 420"/>
            <path class="campus-road" d="M515 265 C530 320 565 340 615 365 C650 383 677 407 692 448"/>
            <path class="campus-road" d="M694 448 C746 460 804 468 953 474"/>
            <path class="campus-sidewalk" d="M52 285 H946"/>
            <path class="campus-sidewalk" d="M530 281 C530 322 505 342 462 365 C430 382 414 401 401 431"/>
            <path class="campus-sidewalk" d="M546 283 C558 324 592 347 626 366 C661 385 687 411 704 451"/>

            <g class="campus-node" data-key="Academic Building 1" filter="url(#softShadow)">
              <rect x="70" y="72" width="170" height="145" rx="12" fill="#f7f4ec" stroke="#d2c8b8" stroke-width="3"/>
              <polygon points="70,72 155,43 240,72 155,101" fill="#d97848"/>
              <polygon points="240,72 240,217 155,246 155,101" fill="#d9dfda"/>
              <rect x="91" y="105" width="128" height="82" rx="5" fill="#fff"/>
              <g class="windows"><rect x="103" y="117" width="18" height="22"/><rect x="132" y="117" width="18" height="22"/><rect x="161" y="117" width="18" height="22"/><rect x="190" y="117" width="18" height="22"/><rect x="103" y="150" width="18" height="22"/><rect x="132" y="150" width="18" height="22"/><rect x="161" y="150" width="18" height="22"/><rect x="190" y="150" width="18" height="22"/></g>
            </g>
            <g class="campus-node" data-key="Academic Building 2" filter="url(#softShadow)">
              <rect x="275" y="72" width="170" height="145" rx="12" fill="#f7f4ec" stroke="#d2c8b8" stroke-width="3"/>
              <polygon points="275,72 360,43 445,72 360,101" fill="#4b8edc"/>
              <polygon points="445,72 445,217 360,246 360,101" fill="#d9dfda"/>
              <rect x="296" y="105" width="128" height="82" rx="5" fill="#fff"/>
              <g class="windows"><rect x="308" y="117" width="18" height="22"/><rect x="337" y="117" width="18" height="22"/><rect x="366" y="117" width="18" height="22"/><rect x="395" y="117" width="18" height="22"/><rect x="308" y="150" width="18" height="22"/><rect x="337" y="150" width="18" height="22"/><rect x="366" y="150" width="18" height="22"/><rect x="395" y="150" width="18" height="22"/></g>
            </g>
            <g class="campus-node" data-key="Academic Building 3" filter="url(#softShadow)">
              <rect x="480" y="72" width="170" height="145" rx="12" fill="#f7f4ec" stroke="#d2c8b8" stroke-width="3"/>
              <polygon points="480,72 565,43 650,72 565,101" fill="#8b5bd8"/>
              <polygon points="650,72 650,217 565,246 565,101" fill="#d9dfda"/>
              <rect x="501" y="105" width="128" height="82" rx="5" fill="#fff"/>
              <g class="windows"><rect x="513" y="117" width="18" height="22"/><rect x="542" y="117" width="18" height="22"/><rect x="571" y="117" width="18" height="22"/><rect x="600" y="117" width="18" height="22"/><rect x="513" y="150" width="18" height="22"/><rect x="542" y="150" width="18" height="22"/><rect x="571" y="150" width="18" height="22"/><rect x="600" y="150" width="18" height="22"/></g>
            </g>

            <g class="campus-node" data-key="Basketball Court">
              <rect x="690" y="86" width="185" height="122" rx="16" fill="#5c8e72" stroke="#fff" stroke-width="7"/>
              <rect x="707" y="101" width="151" height="92" rx="10" fill="#d85c4d" stroke="#f9eee6" stroke-width="3"/>
              <path d="M782 101 V193 M707 147 H858" stroke="#fff" stroke-width="3" opacity=".9"/><circle cx="782" cy="147" r="18" fill="none" stroke="#fff" stroke-width="3"/>
              <path d="M707 123 H735 A24 24 0 0 1 735 171 H707 M858 123 H830 A24 24 0 0 0 830 171 H858" fill="none" stroke="#fff" stroke-width="3"/>
            </g>
            <g class="campus-node" data-key="Student Hostel" filter="url(#softShadow)">
              <rect x="900" y="65" width="65" height="182" rx="12" fill="#eeeae1" stroke="#c9c0af" stroke-width="3"/>
              <polygon points="900,65 932,48 965,65 932,82" fill="#7f5fd1"/>
              <g class="windows"><rect x="914" y="96" width="13" height="18"/><rect x="938" y="96" width="13" height="18"/><rect x="914" y="128" width="13" height="18"/><rect x="938" y="128" width="13" height="18"/><rect x="914" y="160" width="13" height="18"/><rect x="938" y="160" width="13" height="18"/><rect x="914" y="192" width="13" height="18"/><rect x="938" y="192" width="13" height="18"/></g>
            </g>

            <g class="campus-node" data-key="Gazebo" filter="url(#softShadow)">
              <circle cx="370" cy="430" r="74" fill="#d9e9ce" opacity=".9"/>
              <ellipse cx="370" cy="431" rx="58" ry="42" fill="#c9864f" stroke="#8d5a35" stroke-width="4"/>
              <polygon points="307,410 370,367 433,410 370,453" fill="#b55c3d"/>
              <rect x="327" y="408" width="86" height="44" rx="4" fill="#e8d8b9"/>
              <path d="M340 408 V452 M370 408 V452 M400 408 V452" stroke="#8b6849" stroke-width="5"/>
            </g>

            <g class="campus-node" data-key="Main Playground" filter="url(#softShadow)">
              <ellipse cx="650" cy="500" rx="195" ry="88" fill="#b9d6a5" stroke="#d9ad83" stroke-width="15"/>
              <ellipse cx="650" cy="500" rx="174" ry="72" fill="#67ae61" stroke="#fff" stroke-width="3"/>
              <path d="M650 428 V572 M520 500 H780" stroke="#fff" stroke-width="3"/><circle cx="650" cy="500" r="27" fill="none" stroke="#fff" stroke-width="3"/>
              <path d="M520 470 H545 M520 530 H545 M755 470 H780 M755 530 H780" stroke="#fff" stroke-width="3"/>
            </g>
            <g class="campus-node" data-key="Swimming Pool" filter="url(#softShadow)">
              <rect x="850" y="430" width="110" height="145" rx="16" fill="#e6e8e0" stroke="#fff" stroke-width="8"/>
              <rect x="870" y="450" width="70" height="105" rx="8" fill="#36b5ed" stroke="#2388b8" stroke-width="4"/>
              <path d="M884 468 H926 M884 493 H926 M884 518 H926 M884 543 H926" stroke="#b9ecff" stroke-width="4"/>
            </g>

            <g class="campus-label" data-key="Academic Building 1"><rect x="85" y="28" width="165" height="40" rx="20"/><text x="167" y="53">🏫  Academic Building 1</text></g>
            <g class="campus-label" data-key="Academic Building 2"><rect x="285" y="28" width="165" height="40" rx="20"/><text x="367" y="53">🏫  Academic Building 2</text></g>
            <g class="campus-label" data-key="Academic Building 3"><rect x="485" y="28" width="165" height="40" rx="20"/><text x="567" y="53">🏫  Academic Building 3</text></g>
            <g class="campus-label" data-key="Basketball Court"><rect x="690" y="213" width="185" height="40" rx="20"/><text x="782" y="238">🏀  Basketball Court</text></g>
            <g class="campus-label" data-key="Student Hostel"><rect x="850" y="255" width="110" height="40" rx="20"/><text x="905" y="280">🛏️  Hostel</text></g>
            <g class="campus-label" data-key="Gazebo"><rect x="302" y="480" width="136" height="40" rx="20"/><text x="370" y="505">🌳  Gazebo</text></g>
            <g class="campus-label" data-key="Main Playground"><rect x="580" y="575" width="140" height="38" rx="19"/><text x="650" y="599">🏃  Main Ground</text></g>
            <g class="campus-label" data-key="Swimming Pool"><rect x="818" y="578" width="150" height="38" rx="19"/><text x="893" y="602">🏊  Swimming Pool</text></g>
          </svg>
        </div>
        <div class="campus-toolbar">
          <button id="campusRotate">⟳<span>Rotate</span></button><button id="campusZoomIn">⌕<span>Zoom In</span></button><button id="campusZoomOut">⊖<span>Zoom Out</span></button><button id="campusReset">⌂<span>Reset View</span></button>
        </div>
      </div>
      <aside class="campus-location-card">
        <span class="tag">CAMPUS MAP</span><h3>Select a location</h3><p>Click a building, sports facility or student-life space to see more details.</p>
        <div class="campus-pills">${locationData.map(x=>`<button class="location-pill" data-location="${esc(x.key)}"><span style="background:${x.accent}">${esc(x.icon)}</span>${esc(x.label)}</button>`).join('')}</div>
      </aside>
    </div>
  </div>`);
  const scene=$('#campusScene'), map=$('#campusMap'); let scale=1,angle=0;
  const apply=()=>{map.style.transform=`scale(${scale}) rotate(${angle}deg)`};
  function selectLocation(key){
    const item=locationData.find(x=>x.key===key)||locationData.find(x=>x.label===key); if(!item)return;
    document.querySelectorAll('.location-pill').forEach(b=>b.classList.toggle('selected',b.dataset.location===item.key));
    document.querySelectorAll('.campus-node').forEach(n=>n.classList.toggle('selected',n.dataset.key===item.key));
    const data=item.data;
    const panel=$('.campus-location-card');
    panel.querySelector('.tag').textContent=item.kind==='academic'?'ACADEMIC':item.kind==='court'?'SPORTS':item.kind==='ground'?'SPORTS':'CAMPUS MAP';
    panel.querySelector('h3').textContent=item.label;
    panel.querySelector('p').textContent=data.description||'Campus location.';
  }
  document.querySelectorAll('.campus-node,.campus-label').forEach(n=>n.addEventListener('click',()=>selectLocation(n.dataset.key)));
  document.querySelectorAll('.location-pill').forEach(b=>b.addEventListener('click',()=>selectLocation(b.dataset.location)));
  $('#campusRotate').onclick=()=>{angle=(angle+8)%360;apply()};
  $('#campusZoomIn').onclick=()=>{scale=Math.min(1.35,scale+.1);apply()};
  $('#campusZoomOut').onclick=()=>{scale=Math.max(.8,scale-.1);apply()};
  $('#campusReset').onclick=()=>{scale=1;angle=0;apply();document.querySelectorAll('.selected').forEach(x=>x.classList.remove('selected'))};
  scene.onwheel=e=>{e.preventDefault();scale=Math.max(.8,Math.min(1.35,scale+(e.deltaY<0?.05:-.05)));apply()};
  let dragging=false,lastX=0;
  scene.onpointerdown=e=>{dragging=true;lastX=e.clientX;scene.setPointerCapture(e.pointerId)};
  scene.onpointermove=e=>{if(!dragging)return;angle+=((e.clientX-lastX)*.25);lastX=e.clientX;apply()};
  scene.onpointerup=()=>dragging=false; scene.onpointercancel=()=>dragging=false;
  $('#campusSearch').oninput=e=>{const q=e.target.value.toLowerCase().trim();document.querySelectorAll('.location-pill').forEach(b=>b.style.display=(!q||b.innerText.toLowerCase().includes(q))?'':'none')};
}
async function directory(){let d=await api('directory');shell(`<div class="toolbar"><input id="dirQ" class="input" placeholder="Search name, PRN or branch"><select id="dirBranch" class="select"><option value="">All branches</option><option>IT</option><option>Computer Engineering</option><option>Mechanical</option><option>ENTC</option></select><select id="dirYear" class="select"><option value="">All years</option><option>First Year</option><option>Second Year</option><option>Third Year</option><option>Fourth Year</option></select><button class="btn btn-primary" id="dirSearch">Search</button></div><div class="grid three" id="students">${d.students.map(studentCard).join('')}</div>`);$('#dirSearch').onclick=async()=>{let x=await api('directory',{q:$('#dirQ').value,branch:$('#dirBranch').value,year:$('#dirYear').value});$('#students').innerHTML=x.students.map(studentCard).join('')||empty('No students found')};}
function studentCard(x){return `<div class="card student"><div class="student-avatar">${esc((x.name||'S')[0])}</div><div style="flex:1"><h3>${esc(x.name)}</h3><span class="tag">${esc(x.branch)}</span><p class="muted">${esc(x.year)} · Division ${esc(x.division)} · ${esc(x.studentId)}</p><p class="muted">${esc(x.bio||'MIT Socials student')}</p><button class="btn btn-primary" onclick="viewProfile(${x.id})">View profile</button></div></div>`}
async function viewProfile(id){let d=await api('profile',{id});shell(`<div class="card"><div class="section-head"><div><h2>${esc(d.profile.name)}</h2><p class="muted">${esc(d.profile.branch)} · ${esc(d.profile.year)} · ${esc(d.profile.division)}</p></div><button class="btn btn-ghost" data-view="directory">Back</button></div><p>${esc(d.profile.bio||'No bio')}</p></div><div class="grid three"><div class="card"><h3>Skills</h3>${d.skills.map(x=>`<p>${esc(x.skill_name)} · ${esc(x.proficiency_level)}</p>`).join('')||empty('No skills')}</div><div class="card"><h3>Projects</h3>${d.projects.map(x=>`<p><b>${esc(x.title)}</b><br><span class="muted">${esc(x.technologies_used||'')}</span></p>`).join('')||empty('No projects')}</div><div class="card"><h3>Achievements</h3>${d.achievements.map(x=>`<p>${esc(x.title)} · ${esc(x.category||'')}</p>`).join('')||empty('No achievements')}</div></div>`)}
async function clubs(){let d=await api('clubs');shell(`<div class="hero"><div><span class="tag">VERIFIED CAMPUS CLUBS</span><h2>Find your people.</h2><p>Join technical, sports, cultural, creative and social clubs.</p></div><button class="btn btn-primary" onclick="toast('Club creation is available to Club Admins from Admin.')">Create club</button></div><div class="toolbar" style="margin-top:18px"><input class="input" id="clubQ" placeholder="Search clubs…"></div><div class="grid three" id="clubGrid">${d.clubs.map(clubCard).join('')}</div>`);$('#clubQ').oninput=e=>{let q=e.target.value.toLowerCase();document.querySelectorAll('#clubGrid .club').forEach(x=>x.parentElement.style.display=x.innerText.toLowerCase().includes(q)?'':'none')};}
async function events(){let d=await api('events');shell(`<div class="hero"><div><span class="tag">CAMPUS CALENDAR</span><h2>What's happening next?</h2><p>Technical, sports, cultural, workshops, hackathons, seminars and fests.</p></div></div><div class="list" style="margin-top:18px">${d.events.map(eventCard).join('')||empty('No upcoming events')}</div>`)}
async function yearbook(){let d=await api('directory');shell(`<div class="hero"><div><span class="tag">DIGITAL YEARBOOK</span><h2>Meet the people who make MIT.</h2><p>Browse students by batch, branch and division.</p></div></div><div class="grid four" style="margin-top:18px">${d.students.map(studentCard).join('')}</div>`)}
async function messages(){let d=await api('messages');shell(`<div class="grid two"><div class="card"><h2>Messages</h2>${d.messages.map(x=>`<div class="message"><div class="student-avatar">${esc((x.senderName||'S')[0])}</div><div><b>${esc(x.senderName)}</b><p>${esc(x.text)}</p><span class="muted">${new Date(x.createdAt).toLocaleString()}</span></div></div>`).join('')||empty('No messages yet')}</div><div class="card"><h2>Start a conversation</h2><input class="input" id="msgTo" placeholder="Student ID"><textarea class="textarea" id="msgText" placeholder="Write a message…" style="width:100%;margin-top:10px"></textarea><button class="btn btn-primary" style="margin-top:10px" onclick="sendMsg()">Send</button></div></div>`)}
async function leaderboard(){let d=await api('leaderboard',{category:'OVERALL'});shell(`<div class="toolbar">${['OVERALL','SPORTS','CULTURAL','PROFESSIONAL','CREATOR','CONTRIBUTOR'].map(c=>`<button class="btn btn-ghost" onclick="loadBoard('${c}')">${c}</button>`).join('')}</div><div class="card"><table class="table"><thead><tr><th>Rank</th><th>Student</th><th>Branch</th><th>Points</th></tr></thead><tbody id="board">${d.leaders.map(x=>`<tr><td>#${x.rank}</td><td><b>${esc(x.name)}</b></td><td>${esc(x.branch)}</td><td><b>${x.points}</b></td></tr>`).join('')}</tbody></table></div>`)}
async function loadBoard(c){let d=await api('leaderboard',{category:c});$('#board').innerHTML=d.leaders.map(x=>`<tr><td>#${x.rank}</td><td><b>${esc(x.name)}</b></td><td>${esc(x.branch)}</td><td><b>${x.points}</b></td></tr>`).join('')||'<tr><td colspan="4">No rankings yet</td></tr>'}
async function notifications(){let d=await api('notifications');shell(`<div class="list">${d.notifications.map(x=>`<div class="card"><span class="tag">${esc(x.type)}</span><p>${esc(x.content)}</p><span class="muted">${new Date(x.createdAt).toLocaleString()}</span>${!x.read?`<button class="btn btn-ghost" onclick="markNotif(${x.id})">Mark read</button>`:''}</div>`).join('')||empty('No notifications')}</div>`)}
async function admin(){if(!['COLLEGE_ADMIN','CLUB_ADMIN'].includes(sessionUser.role)){shell(`<div class="card"><h2>Admin access required</h2><p class="muted">This area is restricted to Club Admin and College Admin roles.</p></div>`);return}shell(`<div class="grid three"><div class="card"><h2>Students</h2><p class="muted">Review profiles and roles.</p></div><div class="card"><h2>Clubs</h2><p class="muted">Manage verified clubs and announcements.</p></div><div class="card"><h2>Events</h2><p class="muted">Create and manage campus events.</p></div></div><div class="card"><h2>Administration workflow</h2><p>Use the database-backed modules to manage students, clubs and events. The next admin actions can be added without changing the frontend architecture.</p></div>`)}
async function clubAction(id,join){try{await api(join?'joinClub':'leaveClub',{club_id:id},'POST');toast(join?'Joined club':'Left club');show('clubs')}catch(e){toast(e.message)}}
async function communityAction(id,join){try{await api(join?'joinCommunity':'leaveCommunity',{community_id:id},'POST');toast(join?'Joined community':'Left community');show('community')}catch(e){toast(e.message)}}
async function eventAction(id,join){try{await api(join?'registerEvent':'cancelEvent',{event_id:id},'POST');toast(join?'Registered for event':'Registration cancelled');show('events')}catch(e){toast(e.message)}}
async function commentPost(id){let text=prompt('Write a comment');if(!text)return;try{await api('comment',{post_id:id,text},'POST');toast('Comment added');show('community')}catch(e){toast(e.message)}}
async function likePost(id,on){try{await api(on?'like':'unlike',{post_id:id},'POST');show('community')}catch(e){toast(e.message)}}
async function createPost(){let text=prompt('What do you want to share with campus?');if(!text)return;try{await api('createPost',{caption:text,post_type:'TEXT'},'POST');toast('Post created');show('community')}catch(e){toast(e.message)}}
async function sendMsg(){let receiver=Number($('#msgTo').value);let text=$('#msgText').value;if(!receiver||!text.trim()){toast('Enter a student ID and message');return}try{await api('sendMessage',{receiver_id:receiver,message:text},'POST');toast('Message sent');show('messages')}catch(e){toast(e.message)}}
async function markNotif(id){await api('markNotification',{notification_id:id},'POST');show('notifications')}
$('#logout').onclick=async()=>{await fetch('api/logout');location.href='login.html'};$('#theme').onclick=()=>document.body.classList.toggle('dark');$('#menu').onclick=()=>document.getElementById('sidebar').classList.toggle('open');document.querySelectorAll('[data-view]').forEach(x=>x.onclick=()=>show(x.dataset.view));
(async()=>{let u=await session();if(u)show('home')})();
