const puppeteer=require('puppeteer-core');const path=require('path');
function url(f){return 'file:///'+path.resolve(f).replace(/\\/g,'/');}
(async()=>{
  const b=await puppeteer.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:'new',args:['--no-sandbox']});
  // PDHL
  let p=await b.newPage();await p.setViewport({width:390,height:844,deviceScaleFactor:2,isMobile:true});
  let errs=[];p.on('pageerror',e=>errs.push(e.message));
  await p.goto(url('propuesta/plan_desarrollo_humano.html'),{waitUntil:'networkidle2'});await new Promise(r=>setTimeout(r,400));
  await p.click('#lang-btn');await new Promise(r=>setTimeout(r,300));
  let h1=await p.$eval('h1',e=>e.textContent.trim());
  let ov=await p.evaluate(()=>document.documentElement.scrollWidth>window.innerWidth+1);
  console.log('PDHL EN h1:',h1,'| overflow:',ov,'| errores:',errs.length?errs.join('|'):'ninguno');
  await p.close();
  // Simulador
  p=await b.newPage();await p.setViewport({width:390,height:844,deviceScaleFactor:2,isMobile:true});
  errs=[];p.on('pageerror',e=>errs.push(e.message));
  await p.goto(url('propuesta/simulador.html'),{waitUntil:'networkidle2'});await new Promise(r=>setTimeout(r,400));
  await p.click('#lang-btn');await new Promise(r=>setTimeout(r,300));
  const firstOpt=await p.$eval('.opt .ti',e=>e.textContent.trim());
  // jugar: elegir decisión, siguiente, recomendar
  await p.click('#opts .opt');await new Promise(r=>setTimeout(r,400));
  await p.click('#next');await new Promise(r=>setTimeout(r,400));
  const recq=await p.$eval('.recq',e=>e.textContent.trim());
  const favH=await p.$eval('.argcol.fav h4',e=>e.textContent.trim());
  await p.click('.rec');await new Promise(r=>setTimeout(r,400));
  const youchose=await p.$eval('.youchose',e=>e.textContent.trim());
  const ctaA=await p.$eval('.cta a',e=>e.textContent.trim());
  ov=await p.evaluate(()=>document.documentElement.scrollWidth>window.innerWidth+1);
  console.log('SIM EN: firstOpt=',firstOpt);
  console.log('SIM EN: recq=',recq,'| favH=',favH);
  console.log('SIM EN: youchose=',youchose.slice(0,40),'| cta=',ctaA);
  console.log('SIM overflow:',ov,'| errores:',errs.length?errs.join('|'):'ninguno');
  await b.close();
})().catch(e=>{console.error('FALLO',e.message);process.exit(1)});
