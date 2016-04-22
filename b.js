// Javascript supports // one-line comments and /* ... */ comments

// Global variables

var box;
var stateBox;
var cells = [];
var mouseDown = 0;
var enable = 0;
var cix = 0;
var weekdays = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
var nowDate;
var startDate;

// Functions

function init() {
  function addBox( boxclass ) {
    let el = document.createElement( 'div' );
    el.classList.add( boxclass );
    if ( boxclass == 'cell' ) {
      if ( cix & 1 ) el.classList.add( 'b' );
      el.id = 'c' + ( '00' + cix ).substr( -3 );
      el.setAttribute( 'onmousedown',  'togEnable(this);' );
      el.setAttribute( 'onmouseenter', 'dragEnter(this);' );
      el.setAttribute( 'ondragstart',  'return false;'    );   // Needed?? May need 'function(){return false}'
      cells[cix++] = el;
    } else if ( arguments.length > 1 ) el.innerHTML = arguments[1];
    el.setAttribute( 'unselectable', 'on' );
    box.appendChild( el );
  }

  document.body.onmousedown = function() { ++mouseDown; }
  document.body.onmouseup   = function() { if ( --mouseDown < 0 ) mouseDown = 0; }
  box = document.getElementById( 'box' );
  stateBox = document.getElementById( 'statebox' );
  nowDate = new Date();
  startDate = new Date( nowDate.getFullYear(), nowDate.getMonth(), nowDate.getDate() );
  // Header row
  addBox( 'daybox' );
  ['am','pm'].forEach( function( m ) {
    for ( let i = 0; i < 12; i++ ) addBox( 'th', ( i ? i : 12 ) + m );
  });
  // Day rows
  let weekday = nowDate.getDay();
  for ( let row = 0; row < 7; row++ ) {
    addBox( 'daybox', weekdays[ (weekday + row) % 7 ] );
    for ( let i = 96; i--; ) addBox( 'cell' );
  }
}

function togEnable( cell ) {
  cell.classList.toggle('en');
  enable = cell.classList.contains( 'en' );
}

function dragEnter( cell ) {
  if ( mouseDown ) {
    cell.classList.toggle( 'en', enable );
  }
}

function clearState() {
  for ( let ci = 0; ci < 672; ci++ ) cells[ci].classList.toggle( 'en', false );
}

function loadState() {
  let startTS = startDate.getTime();
  let changeTimes = [];
  let states = {};
  function loadState1( ts1, en1 ) {
    changeTimes.push( ts1 );
    states[ ts1 ] = en1;
  }

  let s = stateBox.innerHTML;
  let a = s.split( /\D+/ ).filter( function(t){ return t.length } );
  for ( let i = 0; i < a.length; i += 2 )
    loadState1( 1000 * a[i], a[i+1] == 1 );
  // Add a catchall disable immediately after last cell
  loadState1( startTS + 604800000, false );

  let nextTS;
  let en = false;
  while ( ( nextTS = changeTimes.shift() ) && nextTS <= startTS )
    en = states[ nextTS ];
  let cellTS = startTS;
  for ( let ci = 0; ci < 672; ci++ ) {
    if ( cellTS >= nextTS ) {
      en = states[ nextTS ];
      nextTS = changeTimes.shift();
    }
    cells[ci].classList.toggle( 'en', en );
    cellTS += 900000;
  }
}

function saveState() {
  let ts, cx, lastState, stateStr, thisState;
  function stateLine( tyme, stayt ) {
    //let d = new Date(tyme);
    return '<p>' + Math.floor(tyme.toString() / 1000) + ( stayt ? ' 1 ' : ' 0 ' ) +
           //d.getFullYear() + '-' + zp(d.getMonth()+1) + '-' + zp(d.getDate()) + 'T' +
           //zp(d.getHours()) + ':' + zp(d.getMinutes()) + ':' + zp(d.getSeconds()) +
           //' ' + cx +
           '</p>\n';
  }

  ts = Math.floor( nowDate.getTime() / 900000 ) * 900000;
  cx = Math.floor( (ts - startDate.getTime()) / 900000 );
  lastState = cells[cx].classList.contains('en');
  stateStr = stateLine( ts, lastState );
  while ( ++cx < 672 ) {
    ts += 900000;
    thisState = cells[cx].classList.contains('en');
    if ( thisState != lastState ) {
      stateStr += stateLine( ts, thisState );
      lastState = thisState;
    }
  }
  if ( lastState ) stateStr += stateLine( ts + 900000, false );
  stateBox.innerHTML = stateStr;
}

// Initialisation

document.addEventListener( "DOMContentLoaded", init );

/***************
http://stackoverflow.com/questions/322378/javascript-check-if-mouse-button-down
***************/