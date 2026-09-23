const LIMITS={cycles:[1,2000],fault:[0,.02]};
function validNum(x,[a,b]){return Number.isFinite(Number(x))&&Number(x)>=a&&Number(x)<=b}
export default function handler(req,res){
 if(req.method!=="POST")return res.status(405).json({error:"POST required",protocol:"QHAP/0.1"});
 const b=req.body||{},requestId=String(b.requestId||("REQ-"+Date.now()));
 if(b.protocol!=="QHAP/0.1")return res.status(400).json({protocol:"QHAP/0.1",requestId,error:"protocol_mismatch",failClosed:true});
 if(!["simulator","fpga","qpu"].includes(b.backend))return res.status(400).json({protocol:"QHAP/0.1",requestId,error:"unknown_backend",failClosed:true});
 if(b.backend!=="simulator")return res.status(503).json({protocol:"QHAP/0.1",requestId,backend:b.backend,error:"backend_not_physically_connected",failClosed:true,hardwareVerified:false});
 if(b.operation!=="status"&&b.operation!=="validate")return res.status(400).json({protocol:"QHAP/0.1",requestId,backend:"simulator",error:"unsupported_operation",failClosed:true});
 if(b.operation==="validate"&&(!validNum(b.cycles,LIMITS.cycles)||!validNum(b.fault,LIMITS.fault)))return res.status(400).json({protocol:"QHAP/0.1",requestId,backend:"simulator",error:"parameter_out_of_bounds",failClosed:true});
 return res.status(200).json({protocol:"QHAP/0.1",requestId,backend:"simulator",measurementClass:"simulation",hardwareVerified:false,failClosed:false,safetyGate:"deterministic-boundary",watchdog:"logical-simulation",result:b.operation==="status"?{ready:true,availableBackends:["simulator"],reservedBackends:["fpga","qpu"]}:{valid:true,cycles:Number(b.cycles),fault:Number(b.fault)}});
}