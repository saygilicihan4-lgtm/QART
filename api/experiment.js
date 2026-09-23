function mulberry32(a){return function(){let t=a+=0x6D2B79F5;t=Math.imul(t^t>>>15,t|1);t^=t+Math.imul(t^t>>>7,t|61);return((t^t>>>14)>>>0)/4294967296}}
export default function handler(req,res){
 if(req.method!=="POST")return res.status(405).json({error:"POST required"});
 const b=req.body||{},seed=Math.max(1,Math.min(2147483647,Number(b.seed)||42)),cycles=Math.max(1,Math.min(2000,Number(b.cycles)||240)),mode=["baseline","qart"].includes(b.mode)?b.mode:"qart",fault=Math.max(0,Math.min(0.02,Number(b.fault)||0.007));
 const r=mulberry32(seed);let q=Array.from({length:16},(_,i)=>({id:i,f:.997-r()*.001,n:.00025+r()*.0001,d:0})),events=0,series=[];
 for(let t=0;t<cycles;t++){q.forEach(x=>{x.d+=(r()-.5)*.00012;x.n=Math.max(.0001,x.n+(r()-.5)*.00003);if(t===Math.floor(cycles*.25)&&x.id===seed%16)x.d+=fault;x.f=Math.max(.96,.9975-Math.abs(x.d)-x.n);if(mode==="qart"){let risk=Math.max(0,.995-x.f)*120+Math.max(0,Math.abs(x.d)-.001)*100;if(risk>.48){x.d*=.15;x.n=Math.max(.0002,x.n*.6);x.f=.9975-Math.abs(x.d)-x.n;events++}}});if(t%Math.max(1,Math.floor(cycles/60))===0)series.push(q.reduce((a,x)=>a+x.f,0)/16)}
 const mean=q.reduce((a,x)=>a+x.f,0)/16,availability=q.filter(x=>x.f>=.992).length/16,id="QX-"+seed+"-"+cycles+"-"+mode.toUpperCase();
 res.setHeader("Cache-Control","no-store");return res.status(200).json({experimentId:id,engine:"QART Digital Twin API v1",claimBoundary:"simulation",seed,cycles,mode,fault,meanFidelity:mean,availability,interventions:events,series,qubits:q.map(x=>({id:x.id,fidelity:x.f}))});
}