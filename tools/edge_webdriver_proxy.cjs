const http = require('node:http');
http.createServer((req, res) => {
  const chunks=[];
  req.on('data', chunk => chunks.push(chunk));
  req.on('end', () => {
    let body=Buffer.concat(chunks);
    if(req.method==='POST' && req.url==='/session') {
      const data=JSON.parse(body.toString());
      for(const capability of [data.desiredCapabilities, data.capabilities?.alwaysMatch, ...(data.capabilities?.firstMatch ?? [])]) {
        if(capability && capability.browserName === 'edge') {
          capability.browserName='MicrosoftEdge';
          capability['ms:edgeOptions']={args:['--headless=new','--disable-gpu']};
        }
      }
      body=Buffer.from(JSON.stringify(data));
    }
    const headers={...req.headers,'content-length':body.length};
    const upstream=http.request({hostname:'127.0.0.1',port:4444,path:req.url,method:req.method,headers}, response=>{res.writeHead(response.statusCode,response.headers);response.pipe(res);});
    upstream.on('error', err=>{res.writeHead(502);res.end(err.message);});
    upstream.end(body);
  });
}).listen(4445,'127.0.0.1');
