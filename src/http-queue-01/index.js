module.exports = function (context, req) {
    let name = (req.query.name || req.body.name);
    let id = (req.query.id || req.body.id);
    if (req.query.name || (req.body && req.body.name)) {
        context.res = {
            body: "Hello " + name + " id="+id
        }
        context.log('Hello '+name + ' id='+id)        
        context.bindings.out = {"name": name, "id": id }
        context.log('JavaScript HTTP trigger function processed a request and push to queue. '+name+' id ='+id);
    }
    else {
        context.log('JavaScript HTTP trigger function failed to find name');
    context.res = {
            status: 400,
            body: "Please pass a name on the query string or in the request body"
    };
    }
    context.done();
};