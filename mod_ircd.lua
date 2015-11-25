package.preload['verse']=(function(...)
package.preload['util.encodings']=(function(...)
local function e()
error("Function not implemented");
end
local t=require"mime";
module"encodings"
stringprep={};
base64={encode=t.b64,decode=e};
return _M;
end)
package.preload['util.hashes']=(function(...)
local e=require"util.sha1";
return{sha1=e.sha1};
end)
package.preload['util.sha1']=(function(...)
local c=string.len
local a=string.char
local b=string.byte
local g=string.sub
local m=math.floor
local t=require"bit"
local k=t.bnot
local e=t.band
local y=t.bor
local n=t.bxor
local i=t.lshift
local o=t.rshift
local u,l,d,h,r
local function p(e,t)
return i(e,t)+o(e,32-t)
end
local function s(i)
local t,o
local t=""
for n=1,8 do
o=e(i,15)
if(o<10)then
t=a(o+48)..t
else
t=a(o+87)..t
end
i=m(i/16)
end
return t
end
local function j(t)
local i,o
local n=""
i=c(t)*8
t=t..a(128)
o=56-e(c(t),63)
if(o<0)then
o=o+64
end
for e=1,o do
t=t..a(0)
end
for t=1,8 do
n=a(e(i,255))..n
i=m(i/256)
end
return t..n
end
local function q(w)
local m,t,i,o,f,s,c,v
local a,a
local a={}
while(w~="")do
for e=0,15 do
a[e]=0
for t=1,4 do
a[e]=a[e]*256+b(w,e*4+t)
end
end
for e=16,79 do
a[e]=p(n(n(a[e-3],a[e-8]),n(a[e-14],a[e-16])),1)
end
m=u
t=l
i=d
o=h
f=r
for h=0,79 do
if(h<20)then
s=y(e(t,i),e(k(t),o))
c=1518500249
elseif(h<40)then
s=n(n(t,i),o)
c=1859775393
elseif(h<60)then
s=y(y(e(t,i),e(t,o)),e(i,o))
c=2400959708
else
s=n(n(t,i),o)
c=3395469782
end
v=p(m,5)+s+f+c+a[h]
f=o
o=i
i=p(t,30)
t=m
m=v
end
u=e(u+m,4294967295)
l=e(l+t,4294967295)
d=e(d+i,4294967295)
h=e(h+o,4294967295)
r=e(r+f,4294967295)
w=g(w,65)
end
end
local function a(e,t)
e=j(e)
u=1732584193
l=4023233417
d=2562383102
h=271733878
r=3285377520
q(e)
local e=s(u)..s(l)..s(d)
..s(h)..s(r);
if t then
return e;
else
return(e:gsub("..",function(e)
return string.char(tonumber(e,16));
end));
end
end
_G.sha1={sha1=a};
return _G.sha1;
end)
package.preload['lib.adhoc']=(function(...)
local n,r=require"util.stanza",require"util.uuid";
local h="http://jabber.org/protocol/commands";
local i={}
local s={};
function _cmdtag(e,o,t,a)
local e=n.stanza("command",{xmlns=h,node=e.node,status=o});
if t then e.attr.sessionid=t;end
if a then e.attr.action=a;end
return e;
end
function s.new(e,a,t,o)
return{name=e,node=a,handler=t,cmdtag=_cmdtag,permission=(o or"user")};
end
function s.handle_cmd(o,s,a)
local e=a.tags[1].attr.sessionid or r.generate();
local t={};
t.to=a.attr.to;
t.from=a.attr.from;
t.action=a.tags[1].attr.action or"execute";
t.form=a.tags[1]:child_with_ns("jabber:x:data");
local t,h=o:handler(t,i[e]);
i[e]=h;
local a=n.reply(a);
if t.status=="completed"then
i[e]=nil;
cmdtag=o:cmdtag("completed",e);
elseif t.status=="canceled"then
i[e]=nil;
cmdtag=o:cmdtag("canceled",e);
elseif t.status=="error"then
i[e]=nil;
a=n.error_reply(a,t.error.type,t.error.condition,t.error.message);
s.send(a);
return true;
else
cmdtag=o:cmdtag("executing",e);
end
for t,e in pairs(t)do
if t=="info"then
cmdtag:tag("note",{type="info"}):text(e):up();
elseif t=="warn"then
cmdtag:tag("note",{type="warn"}):text(e):up();
elseif t=="error"then
cmdtag:tag("note",{type="error"}):text(e.message):up();
elseif t=="actions"then
local t=n.stanza("actions");
for a,e in ipairs(e)do
if(e=="prev")or(e=="next")or(e=="complete")then
t:tag(e):up();
else
module:log("error",'Command "'..o.name..
'" at node "'..o.node..'" provided an invalid action "'..e..'"');
end
end
cmdtag:add_child(t);
elseif t=="form"then
cmdtag:add_child((e.layout or e):form(e.values));
elseif t=="result"then
cmdtag:add_child((e.layout or e):form(e.values,"result"));
elseif t=="other"then
cmdtag:add_child(e);
end
end
a:add_child(cmdtag);
s.send(a);
return true;
end
return s;
end)
package.preload['util.rsm']=(function(...)
local h=require"util.stanza".stanza;
local a,i=tostring,tonumber;
local n=type;
local r=pairs;
local s='http://jabber.org/protocol/rsm';
local o={};
do
local e=o;
local function t(e)
return i((e:get_text()));
end
local function a(t)
return t:get_text();
end
e.after=a;
e.before=function(e)
local e=e:get_text();
return e==""or e;
end;
e.max=t;
e.index=t;
e.first=function(e)
return{index=i(e.attr.index);e:get_text()};
end;
e.last=a;
e.count=t;
end
local d=setmetatable({
first=function(t,e)
if n(e)=="table"then
t:tag("first",{index=e.index}):text(e[1]):up();
else
t:tag("first"):text(a(e)):up();
end
end;
before=function(t,e)
if e==true then
t:tag("before"):up();
else
t:tag("before"):text(a(e)):up();
end
end
},{
__index=function(t,e)
return function(t,o)
t:tag(e):text(a(o)):up();
end
end;
});
local function n(e)
local i={};
for t in e:childtags()do
local e=t.name;
local a=e and o[e];
if a then
i[e]=a(t);
end
end
return i;
end
local function i(e)
local t=h("set",{xmlns=s});
for e,a in r(e)do
if o[e]then
d[e](t,a);
end
end
return t;
end
local function t(e)
local e=e:get_child("set",s);
if e and#e.tags>0 then
return n(e);
end
end
return{parse=n,generate=i,get=t};
end)
package.preload['util.stanza']=(function(...)
local t=table.insert;
local d=table.remove;
local w=table.concat;
local s=string.format;
local l=string.match;
local f=tostring;
local u=setmetatable;
local n=pairs;
local i=ipairs;
local o=type;
local v=string.gsub;
local y=string.sub;
local c=string.find;
local e=os;
local m=not e.getenv("WINDIR");
local r,a;
if m then
local t,e=pcall(require,"util.termcolours");
if t then
r,a=e.getstyle,e.getstring;
else
m=nil;
end
end
local p="urn:ietf:params:xml:ns:xmpp-stanzas";
module"stanza"
stanza_mt={__type="stanza"};
stanza_mt.__index=stanza_mt;
local e=stanza_mt;
function stanza(t,a)
local t={name=t,attr=a or{},tags={}};
return u(t,e);
end
local h=stanza;
function e:query(e)
return self:tag("query",{xmlns=e});
end
function e:body(t,e)
return self:tag("body",e):text(t);
end
function e:tag(a,e)
local a=h(a,e);
local e=self.last_add;
if not e then e={};self.last_add=e;end
(e[#e]or self):add_direct_child(a);
t(e,a);
return self;
end
function e:text(t)
local e=self.last_add;
(e and e[#e]or self):add_direct_child(t);
return self;
end
function e:up()
local e=self.last_add;
if e then d(e);end
return self;
end
function e:reset()
self.last_add=nil;
return self;
end
function e:add_direct_child(e)
if o(e)=="table"then
t(self.tags,e);
end
t(self,e);
end
function e:add_child(t)
local e=self.last_add;
(e and e[#e]or self):add_direct_child(t);
return self;
end
function e:get_child(a,t)
for o,e in i(self.tags)do
if(not a or e.name==a)
and((not t and self.attr.xmlns==e.attr.xmlns)
or e.attr.xmlns==t)then
return e;
end
end
end
function e:get_child_text(e,t)
local e=self:get_child(e,t);
if e then
return e:get_text();
end
return nil;
end
function e:child_with_name(t)
for a,e in i(self.tags)do
if e.name==t then return e;end
end
end
function e:child_with_ns(t)
for a,e in i(self.tags)do
if e.attr.xmlns==t then return e;end
end
end
function e:children()
local e=0;
return function(t)
e=e+1
return t[e];
end,self,e;
end
function e:childtags(i,t)
local e=self.tags;
local a,o=1,#e;
return function()
for o=a,o do
local e=e[o];
if(not i or e.name==i)
and((not t and self.attr.xmlns==e.attr.xmlns)
or e.attr.xmlns==t)then
a=o+1;
return e;
end
end
end;
end
function e:maptags(i)
local a,t=self.tags,1;
local n,o=#self,#a;
local e=1;
while t<=o and o>0 do
if self[e]==a[t]then
local i=i(self[e]);
if i==nil then
d(self,e);
d(a,t);
n=n-1;
o=o-1;
e=e-1;
t=t-1;
else
self[e]=i;
a[t]=i;
end
t=t+1;
end
e=e+1;
end
return self;
end
function e:find(a)
local e=1;
local s=#a+1;
repeat
local o,t,i;
local n=y(a,e,e);
if n=="@"then
return self.attr[y(a,e+1)];
elseif n=="{"then
o,e=l(a,"^([^}]+)}()",e+1);
end
t,i,e=l(a,"^([^@/#]*)([/#]?)()",e);
t=t~=""and t or nil;
if e==s then
if i=="#"then
return self:get_child_text(t,o);
end
return self:get_child(t,o);
end
self=self:get_child(t,o);
until not self
end
local d
do
local t={["'"]="&apos;",["\""]="&quot;",["<"]="&lt;",[">"]="&gt;",["&"]="&amp;"};
function d(e)return(v(e,"['&<>\"]",t));end
_M.xml_escape=d;
end
local function y(a,e,h,o,r)
local i=0;
local s=a.name
t(e,"<"..s);
for a,n in n(a.attr)do
if c(a,"\1",1,true)then
local a,s=l(a,"^([^\1]*)\1?(.*)$");
i=i+1;
t(e," xmlns:ns"..i.."='"..o(a).."' ".."ns"..i..":"..s.."='"..o(n).."'");
elseif not(a=="xmlns"and n==r)then
t(e," "..a.."='"..o(n).."'");
end
end
local i=#a;
if i==0 then
t(e,"/>");
else
t(e,">");
for i=1,i do
local i=a[i];
if i.name then
h(i,e,h,o,a.attr.xmlns);
else
t(e,o(i));
end
end
t(e,"</"..s..">");
end
end
function e.__tostring(t)
local e={};
y(t,e,y,d,nil);
return w(e);
end
function e.top_tag(e)
local t="";
if e.attr then
for e,a in n(e.attr)do if o(e)=="string"then t=t..s(" %s='%s'",e,d(f(a)));end end
end
return s("<%s%s>",e.name,t);
end
function e.get_text(e)
if#e.tags==0 then
return w(e);
end
end
function e.get_error(a)
local o,e,t;
local a=a:get_child("error");
if not a then
return nil,nil,nil;
end
o=a.attr.type;
for o,a in i(a.tags)do
if a.attr.xmlns==p then
if not t and a.name=="text"then
t=a:get_text();
elseif not e then
e=a.name;
end
if e and t then
break;
end
end
end
return o,e or"undefined-condition",t;
end
do
local e=0;
function new_id()
e=e+1;
return"lx"..e;
end
end
function preserialize(e)
local a={name=e.name,attr=e.attr};
for i,e in i(e)do
if o(e)=="table"then
t(a,preserialize(e));
else
t(a,e);
end
end
return a;
end
function deserialize(a)
if a then
local s=a.attr;
for e=1,#s do s[e]=nil;end
local h={};
for e in n(s)do
if c(e,"|",1,true)and not c(e,"\1",1,true)then
local t,a=l(e,"^([^|]+)|(.+)$");
h[t.."\1"..a]=s[e];
s[e]=nil;
end
end
for t,e in n(h)do
s[t]=e;
end
u(a,e);
for t,e in i(a)do
if o(e)=="table"then
deserialize(e);
end
end
if not a.tags then
local n={};
for i,e in i(a)do
if o(e)=="table"then
t(n,e);
end
end
a.tags=n;
end
end
return a;
end
local function l(a)
local o,i={},{};
for t,e in n(a.attr)do o[t]=e;end
local o={name=a.name,attr=o,tags=i};
for e=1,#a do
local e=a[e];
if e.name then
e=l(e);
t(i,e);
end
t(o,e);
end
return u(o,e);
end
clone=l;
function message(e,t)
if not t then
return h("message",e);
else
return h("message",e):tag("body"):text(t):up();
end
end
function iq(e)
if e and not e.id then e.id=new_id();end
return h("iq",e or{id=new_id()});
end
function reply(e)
return h(e.name,e.attr and{to=e.attr.from,from=e.attr.to,id=e.attr.id,type=((e.name=="iq"and"result")or e.attr.type)});
end
do
local a={xmlns=p};
function error_reply(e,o,i,t)
local e=reply(e);
e.attr.type="error";
e:tag("error",{type=o})
:tag(i,a):up();
if(t)then e:tag("text",a):text(t):up();end
return e;
end
end
function presence(e)
return h("presence",e);
end
if m then
local u=r("yellow");
local h=r("red");
local l=r("red");
local t=r("magenta");
local r=" "..a(u,"%s")..a(t,"=")..a(h,"'%s'");
local h=a(t,"<")..a(l,"%s").."%s"..a(t,">");
local l=h.."%s"..a(t,"</")..a(l,"%s")..a(t,">");
function e.pretty_print(e)
local t="";
for a,e in i(e)do
if o(e)=="string"then
t=t..d(e);
else
t=t..e:pretty_print();
end
end
local a="";
if e.attr then
for e,t in n(e.attr)do if o(e)=="string"then a=a..s(r,e,f(t));end end
end
return s(l,e.name,a,t,e.name);
end
function e.pretty_top_tag(t)
local e="";
if t.attr then
for t,a in n(t.attr)do if o(t)=="string"then e=e..s(r,t,f(a));end end
end
return s(h,t.name,e);
end
else
e.pretty_print=e.__tostring;
e.pretty_top_tag=e.top_tag;
end
return _M;
end)
package.preload['util.timer']=(function(...)
local a=require"net.server";
local d=math.min
local l=math.huge
local n=require"socket".gettime;
local r=table.insert;
local h=pairs;
local s=type;
local i={};
local e={};
module"timer"
local t;
if not a.event then
function t(o,i)
local n=n();
o=o+n;
if o>=n then
r(e,{o,i});
else
local e=i(n);
if e and s(e)=="number"then
return t(e,i);
end
end
end
a._addtimer(function()
local a=n();
if#e>0 then
for a,t in h(e)do
r(i,t);
end
e={};
end
local e=l;
for h,o in h(i)do
local o,n=o[1],o[2];
if o<=a then
i[h]=nil;
local a=n(a);
if s(a)=="number"then
t(a,n);
e=d(e,a);
end
else
e=d(e,o-a);
end
end
return e;
end);
else
local e=a.event;
local a=a.event_base;
local o=(e.core and e.core.LEAVE)or-1;
function t(i,e)
local t;
t=a:addevent(nil,0,function()
local e=e(n());
if e then
return 0,e;
elseif t then
return o;
end
end
,i);
end
end
add_task=t;
return _M;
end)
package.preload['util.termcolours']=(function(...)
local i,n=table.concat,table.insert;
local t,a=string.char,string.format;
local h=tonumber;
local s=ipairs;
local r=io.write;
local e;
if os.getenv("WINDIR")then
e=require"util.windows";
end
local o=e and e.get_consolecolor and e.get_consolecolor();
module"termcolours"
local d={
reset=0;bright=1,dim=2,underscore=4,blink=5,reverse=7,hidden=8;
black=30;red=31;green=32;yellow=33;blue=34;magenta=35;cyan=36;white=37;
["black background"]=40;["red background"]=41;["green background"]=42;["yellow background"]=43;["blue background"]=44;["magenta background"]=45;["cyan background"]=46;["white background"]=47;
bold=1,dark=2,underline=4,underlined=4,normal=0;
}
local u={
["0"]=o,
["1"]=7+8,
["1;33"]=2+4+8,
["1;31"]=4+8
}
local l={
[1]="font-weight: bold",[2]="opacity: 0.5",[4]="text-decoration: underline",[8]="visibility: hidden",
[30]="color:black",[31]="color:red",[32]="color:green",[33]="color:#FFD700",
[34]="color:blue",[35]="color: magenta",[36]="color:cyan",[37]="color: white",
[40]="background-color:black",[41]="background-color:red",[42]="background-color:green",
[43]="background-color:yellow",[44]="background-color:blue",[45]="background-color: magenta",
[46]="background-color:cyan",[47]="background-color: white";
};
local c=t(27).."[%sm%s"..t(27).."[0m";
function getstring(t,e)
if t then
return a(c,t,e);
else
return e;
end
end
function getstyle(...)
local e,t={...},{};
for a,e in s(e)do
e=d[e];
if e then
n(t,e);
end
end
return i(t,";");
end
local a="0";
function setstyle(e)
e=e or"0";
if e~=a then
r("\27["..e.."m");
a=e;
end
end
if e then
function setstyle(t)
t=t or"0";
if t~=a then
e.set_consolecolor(u[t]or o);
a=t;
end
end
if not o then
function setstyle(e)end
end
end
local function a(e)
if e=="0"then return"</span>";end
local t={};
for e in e:gmatch("[^;]+")do
n(t,l[h(e)]);
end
return"</span><span style='"..i(t,";").."'>";
end
function tohtml(e)
return e:gsub("\027%[(.-)m",a);
end
return _M;
end)
package.preload['util.uuid']=(function(...)
local e=math.random;
local o=tostring;
local e=os.time;
local n=os.clock;
local i=require"util.hashes".sha1;
module"uuid"
local t=0;
local function a()
local e=e();
if t>=e then e=t+1;end
t=e;
return e;
end
local function t(e)
return i(e..n()..o({}),true);
end
local e=t(a());
local function o(a)
e=t(e..a);
end
local function t(t)
if#e<t then o(a());end
local a=e:sub(0,t);
e=e:sub(t+1);
return a;
end
local function e()
return("%x"):format(t(1):byte()%4+8);
end
function generate()
return t(8).."-"..t(4).."-4"..t(3).."-"..(e())..t(3).."-"..t(12);
end
seed=o;
return _M;
end)
package.preload['net.dns']=(function(...)
local s=require"socket";
local j=require"util.timer";
local e,v=pcall(require,"util.windows");
local _=(e and v)or os.getenv("WINDIR");
local u,z,b,a,i=
coroutine,io,math,string,table;
local c,n,o,f,r,p,k,x,t,e,q=
ipairs,next,pairs,print,setmetatable,tostring,assert,error,unpack,select,type;
local e={
get=function(t,...)
local a=e('#',...);
for a=1,a do
t=t[e(a,...)];
if t==nil then break;end
end
return t;
end;
set=function(a,...)
local s=e('#',...);
local h,o=e(s-1,...);
local t,i;
for s=1,s-2 do
local s=e(s,...)
local e=a[s]
if o==nil then
if e==nil then
return;
elseif n(e,n(e))then
t=nil;i=nil;
elseif t==nil then
t=a;i=s;
end
elseif e==nil then
e={};
a[s]=e;
end
a=e
end
if o==nil and t then
t[i]=nil;
else
a[h]=o;
return o;
end
end;
};
local d,l=e.get,e.set;
local E=15;
module('dns')
local t=_M;
local h=i.insert
local function m(e)
return(e-(e%256))/256;
end
local function w(e)
local t={};
for o,e in o(e)do
t[o]=e;
t[e]=e;
t[a.lower(e)]=e;
end
return t;
end
local function y(i)
local e={};
for t,i in o(i)do
local o=a.char(m(t),t%256);
e[t]=o;
e[i]=o;
e[a.lower(i)]=o;
end
return e;
end
t.types={
'A','NS','MD','MF','CNAME','SOA','MB','MG','MR','NULL','WKS',
'PTR','HINFO','MINFO','MX','TXT',
[28]='AAAA',[29]='LOC',[33]='SRV',
[252]='AXFR',[253]='MAILB',[254]='MAILA',[255]='*'};
t.classes={'IN','CS','CH','HS',[255]='*'};
t.type=w(t.types);
t.class=w(t.classes);
t.typecode=y(t.types);
t.classcode=y(t.classes);
local function g(e,i,o)
if a.byte(e,-1)~=46 then e=e..'.';end
e=a.lower(e);
return e,t.type[i or'A'],t.class[o or'IN'];
end
local function y(t,a,o)
a=a or s.gettime();
for n,e in c(t)do
if e.tod then
e.ttl=b.floor(e.tod-a);
if e.ttl<=0 then
t[e[e.type:lower()]]=nil;
i.remove(t,n);
return y(t,a,o);
end
elseif o=='soft'then
k(e.ttl==0);
t[e[e.type:lower()]]=nil;
i.remove(t,n);
end
end
end
local e={};
e.__index=e;
e.timeout=E;
local function w(e)
local e=e.type and e[e.type:lower()];
if q(e)~="string"then
return"<UNKNOWN RDATA TYPE>";
end
return e;
end
local k={
LOC=e.LOC_tostring;
MX=function(e)
return a.format('%2i %s',e.pref,e.mx);
end;
SRV=function(e)
local e=e.srv;
return a.format('%5d %5d %5d %s',e.priority,e.weight,e.port,e.target);
end;
};
local q={};
function q.__tostring(e)
local t=(k[e.type]or w)(e);
return a.format('%2s %-5s %6i %-28s %s',e.class,e.type,e.ttl,e.name,t);
end
local k={};
function k.__tostring(t)
local e={};
for a,t in c(t)do
h(e,p(t)..'\n');
end
return i.concat(e);
end
local w={};
function w.__tostring(t)
local a=s.gettime();
local e={};
for i,t in o(t)do
for i,t in o(t)do
for o,t in o(t)do
y(t,a);
h(e,p(t));
end
end
end
return i.concat(e);
end
function e:new()
local t={active={},cache={},unsorted={}};
r(t,e);
r(t.cache,w);
r(t.unsorted,{__mode='kv'});
return t;
end
function t.random(...)
b.randomseed(b.floor(1e4*s.gettime())%2147483648);
t.random=b.random;
return t.random(...);
end
local function E(e)
e=e or{};
e.id=e.id or t.random(0,65535);
e.rd=e.rd or 1;
e.tc=e.tc or 0;
e.aa=e.aa or 0;
e.opcode=e.opcode or 0;
e.qr=e.qr or 0;
e.rcode=e.rcode or 0;
e.z=e.z or 0;
e.ra=e.ra or 0;
e.qdcount=e.qdcount or 1;
e.ancount=e.ancount or 0;
e.nscount=e.nscount or 0;
e.arcount=e.arcount or 0;
local t=a.char(
m(e.id),e.id%256,
e.rd+2*e.tc+4*e.aa+8*e.opcode+128*e.qr,
e.rcode+16*e.z+128*e.ra,
m(e.qdcount),e.qdcount%256,
m(e.ancount),e.ancount%256,
m(e.nscount),e.nscount%256,
m(e.arcount),e.arcount%256
);
return t,e.id;
end
local function m(t)
local e={};
for t in a.gmatch(t,'[^.]+')do
h(e,a.char(a.len(t)));
h(e,t);
end
h(e,a.char(0));
return i.concat(e);
end
local function b(o,a,e)
o=m(o);
a=t.typecode[a or'a'];
e=t.classcode[e or'in'];
return o..a..e;
end
function e:byte(e)
e=e or 1;
local o=self.offset;
local t=o+e-1;
if t>#self.packet then
x(a.format('out of bounds: %i>%i',t,#self.packet));
end
self.offset=o+e;
return a.byte(self.packet,o,t);
end
function e:word()
local t,e=self:byte(2);
return 256*t+e;
end
function e:dword()
local o,t,a,e=self:byte(4);
return 16777216*o+65536*t+256*a+e;
end
function e:sub(e)
e=e or 1;
local t=a.sub(self.packet,self.offset,self.offset+e-1);
self.offset=self.offset+e;
return t;
end
function e:header(t)
local e=self:word();
if not self.active[e]and not t then return nil;end
local e={id=e};
local t,a=self:byte(2);
e.rd=t%2;
e.tc=t/2%2;
e.aa=t/4%2;
e.opcode=t/8%16;
e.qr=t/128;
e.rcode=a%16;
e.z=a/16%8;
e.ra=a/128;
e.qdcount=self:word();
e.ancount=self:word();
e.nscount=self:word();
e.arcount=self:word();
for a,t in o(e)do e[a]=t-t%1;end
return e;
end
function e:name()
local a,t=nil,0;
local e=self:byte();
local o={};
if e==0 then return"."end
while e>0 do
if e>=192 then
t=t+1;
if t>=20 then x('dns error: 20 pointers');end;
local e=((e-192)*256)+self:byte();
a=a or self.offset;
self.offset=e+1;
else
h(o,self:sub(e)..'.');
end
e=self:byte();
end
self.offset=a or self.offset;
return i.concat(o);
end
function e:question()
local e={};
e.name=self:name();
e.type=t.type[self:word()];
e.class=t.class[self:word()];
return e;
end
function e:A(e)
local o,t,n,i=self:byte(4);
e.a=a.format('%i.%i.%i.%i',o,t,n,i);
end
function e:AAAA(a)
local e={};
for t=1,a.rdlength,2 do
local a,t=self:byte(2);
i.insert(e,("%02x%02x"):format(a,t));
end
e=i.concat(e,":"):gsub("%f[%x]0+(%x)","%1");
local t={};
for e in e:gmatch(":[0:]+:")do
i.insert(t,e)
end
if#t==0 then
a.aaaa=e;
return
elseif#t>1 then
i.sort(t,function(t,e)return#t>#e end);
end
a.aaaa=e:gsub(t[1],"::",1):gsub("^0::","::"):gsub("::0$","::");
end
function e:CNAME(e)
e.cname=self:name();
end
function e:MX(e)
e.pref=self:word();
e.mx=self:name();
end
function e:LOC_nibble_power()
local e=self:byte();
return((e-(e%16))/16)*(10^(e%16));
end
function e:LOC(e)
e.version=self:byte();
if e.version==0 then
e.loc=e.loc or{};
e.loc.size=self:LOC_nibble_power();
e.loc.horiz_pre=self:LOC_nibble_power();
e.loc.vert_pre=self:LOC_nibble_power();
e.loc.latitude=self:dword();
e.loc.longitude=self:dword();
e.loc.altitude=self:dword();
end
end
local function m(e,i,t)
e=e-2147483648;
if e<0 then i=t;e=-e;end
local n,t,o;
o=e%6e4;
e=(e-o)/6e4;
t=e%60;
n=(e-t)/60;
return a.format('%3d %2d %2.3f %s',n,t,o/1e3,i);
end
function e.LOC_tostring(e)
local t={};
h(t,a.format(
'%s    %s    %.2fm %.2fm %.2fm %.2fm',
m(e.loc.latitude,'N','S'),
m(e.loc.longitude,'E','W'),
(e.loc.altitude-1e7)/100,
e.loc.size/100,
e.loc.horiz_pre/100,
e.loc.vert_pre/100
));
return i.concat(t);
end
function e:NS(e)
e.ns=self:name();
end
function e:SOA(e)
end
function e:SRV(e)
e.srv={};
e.srv.priority=self:word();
e.srv.weight=self:word();
e.srv.port=self:word();
e.srv.target=self:name();
end
function e:PTR(e)
e.ptr=self:name();
end
function e:TXT(e)
e.txt=self:sub(self:byte());
end
function e:rr()
local e={};
r(e,q);
e.name=self:name(self);
e.type=t.type[self:word()]or e.type;
e.class=t.class[self:word()]or e.class;
e.ttl=65536*self:word()+self:word();
e.rdlength=self:word();
if e.ttl<=0 then
e.tod=self.time+30;
else
e.tod=self.time+e.ttl;
end
local a=self.offset;
local t=self[t.type[e.type]];
if t then t(self,e);end
self.offset=a;
e.rdata=self:sub(e.rdlength);
return e;
end
function e:rrs(t)
local e={};
for t=1,t do h(e,self:rr());end
return e;
end
function e:decode(t,o)
self.packet,self.offset=t,1;
local t=self:header(o);
if not t then return nil;end
local t={header=t};
t.question={};
local i=self.offset;
for e=1,t.header.qdcount do
h(t.question,self:question());
end
t.question.raw=a.sub(self.packet,i,self.offset-1);
if not o then
if not self.active[t.header.id]or not self.active[t.header.id][t.question.raw]then
self.active[t.header.id]=nil;
return nil;
end
end
t.answer=self:rrs(t.header.ancount);
t.authority=self:rrs(t.header.nscount);
t.additional=self:rrs(t.header.arcount);
return t;
end
e.delays={1,3};
function e:addnameserver(e)
self.server=self.server or{};
h(self.server,e);
end
function e:setnameserver(e)
self.server={};
self:addnameserver(e);
end
function e:adddefaultnameservers()
if _ then
if v and v.get_nameservers then
for t,e in c(v.get_nameservers())do
self:addnameserver(e);
end
end
if not self.server or#self.server==0 then
self:addnameserver("208.67.222.222");
self:addnameserver("208.67.220.220");
end
else
local e=z.open("/etc/resolv.conf");
if e then
for e in e:lines()do
e=e:gsub("#.*$","")
:match('^%s*nameserver%s+(.*)%s*$');
if e then
e:gsub("%f[%d.](%d+%.%d+%.%d+%.%d+)%f[^%d.]",function(e)
self:addnameserver(e)
end);
end
end
end
if not self.server or#self.server==0 then
self:addnameserver("127.0.0.1");
end
end
end
function e:getsocket(a)
self.socket=self.socket or{};
self.socketset=self.socketset or{};
local e=self.socket[a];
if e then return e;end
local o,t;
e,t=s.udp();
if e and self.socket_wrapper then e,t=self.socket_wrapper(e,self);end
if not e then
return nil,t;
end
e:settimeout(0);
self.socket[a]=e;
self.socketset[e]=a;
o,t=e:setsockname('*',0);
if not o then return self:servfail(e,t);end
o,t=e:setpeername(self.server[a],53);
if not o then return self:servfail(e,t);end
return e;
end
function e:voidsocket(e)
if self.socket[e]then
self.socketset[self.socket[e]]=nil;
self.socket[e]=nil;
elseif self.socketset[e]then
self.socket[self.socketset[e]]=nil;
self.socketset[e]=nil;
end
e:close();
end
function e:socket_wrapper_set(e)
self.socket_wrapper=e;
end
function e:closeall()
for t,e in c(self.socket)do
self.socket[t]=nil;
self.socketset[e]=nil;
e:close();
end
end
function e:remember(e,t)
local i,o,a=g(e.name,e.type,e.class);
if t~='*'then
t=o;
local t=d(self.cache,a,'*',i);
if t then h(t,e);end
end
self.cache=self.cache or r({},w);
local a=d(self.cache,a,t,i)or
l(self.cache,a,t,i,r({},k));
if not a[e[o:lower()]]then
a[e[o:lower()]]=true;
h(a,e);
end
if t=='MX'then self.unsorted[a]=true;end
end
local function m(e,t)
return(e.pref==t.pref)and(e.mx<t.mx)or(e.pref<t.pref);
end
function e:peek(o,a,t,h)
o,a,t=g(o,a,t);
local e=d(self.cache,t,a,o);
if not e then
if h then if h<=0 then return end else h=3 end
e=d(self.cache,t,"CNAME",o);
if not(e and e[1])then return end
return self:peek(e[1].cname,a,t,h-1);
end
if y(e,s.gettime())and a=='*'or not n(e)then
l(self.cache,t,a,o,nil);
return nil;
end
if self.unsorted[e]then i.sort(e,m);self.unsorted[e]=nil;end
return e;
end
function e:purge(e)
if e=='soft'then
self.time=s.gettime();
for t,e in o(self.cache or{})do
for t,e in o(e)do
for t,e in o(e)do
y(e,self.time,'soft')
end
end
end
else self.cache=r({},w);end
end
function e:query(e,t,a)
e,t,a=g(e,t,a)
local n=u.running();
local o=d(self.wanted,a,t,e);
if n and o then
l(self.wanted,a,t,e,n,true);
return true;
end
if not self.server then self:adddefaultnameservers();end
local h=b(e,t,a);
local o=self:peek(e,t,a);
if o then return o;end
local i,o=E();
local i={
packet=i..h,
server=self.best_server,
delay=1,
retry=s.gettime()+self.delays[1]
};
self.active[o]=self.active[o]or{};
self.active[o][h]=i;
if n then
l(self.wanted,a,t,e,n,true);
end
local o,h=self:getsocket(i.server)
if not o then
return nil,h;
end
o:send(i.packet)
if j and self.timeout then
local r=#self.server;
local s=1;
j.add_task(self.timeout,function()
if d(self.wanted,a,t,e,n)then
if s<r then
s=s+1;
self:servfail(o);
i.server=self.best_server;
o,h=self:getsocket(i.server);
if o then
o:send(i.packet);
return self.timeout;
end
end
self:cancel(a,t,e);
end
end)
end
return true;
end
function e:servfail(t,i)
local h=self.socketset[t]
t=self:voidsocket(t);
self.time=s.gettime();
for s,a in o(self.active)do
for o,e in o(a)do
if e.server==h then
e.server=e.server+1
if e.server>#self.server then
e.server=1;
end
e.retries=(e.retries or 0)+1;
if e.retries>=#self.server then
a[o]=nil;
else
t,i=self:getsocket(e.server);
if t then t:send(e.packet);end
end
end
end
if n(a)==nil then
self.active[s]=nil;
end
end
if h==self.best_server then
self.best_server=self.best_server+1;
if self.best_server>#self.server then
self.best_server=1;
end
end
return t,i;
end
function e:settimeout(e)
self.timeout=e;
end
function e:receive(t)
self.time=s.gettime();
t=t or self.socket;
local e;
for a,t in o(t)do
if self.socketset[t]then
local t=t:receive();
if t then
e=self:decode(t);
if e and self.active[e.header.id]
and self.active[e.header.id][e.question.raw]then
for a,t in o(e.answer)do
self:remember(t,e.question[1].type)
end
local t=self.active[e.header.id];
t[e.question.raw]=nil;
if not n(t)then self.active[e.header.id]=nil;end
if not n(self.active)then self:closeall();end
local e=e.question[1];
local t=d(self.wanted,e.class,e.type,e.name);
if t then
for e in o(t)do
if u.status(e)=="suspended"then u.resume(e);end
end
l(self.wanted,e.class,e.type,e.name,nil);
end
end
end
end
end
return e;
end
function e:feed(a,e,t)
self.time=s.gettime();
local e=self:decode(e,t);
if e and self.active[e.header.id]
and self.active[e.header.id][e.question.raw]then
for a,t in o(e.answer)do
self:remember(t,e.question[1].type);
end
local t=self.active[e.header.id];
t[e.question.raw]=nil;
if not n(t)then self.active[e.header.id]=nil;end
if not n(self.active)then self:closeall();end
local e=e.question[1];
if e then
local t=d(self.wanted,e.class,e.type,e.name);
if t then
for e in o(t)do
if u.status(e)=="suspended"then u.resume(e);end
end
l(self.wanted,e.class,e.type,e.name,nil);
end
end
end
return e;
end
function e:cancel(i,t,e)
local a=d(self.wanted,i,t,e);
if a then
for e in o(a)do
if u.status(e)=="suspended"then u.resume(e);end
end
l(self.wanted,i,t,e,nil);
end
end
function e:pulse()
while self:receive()do end
if not n(self.active)then return nil;end
self.time=s.gettime();
for i,t in o(self.active)do
for a,e in o(t)do
if self.time>=e.retry then
e.server=e.server+1;
if e.server>#self.server then
e.server=1;
e.delay=e.delay+1;
end
if e.delay>#self.delays then
t[a]=nil;
if not n(t)then self.active[i]=nil;end
if not n(self.active)then return nil;end
else
local t=self.socket[e.server];
if t then t:send(e.packet);end
e.retry=self.time+self.delays[e.delay];
end
end
end
end
if n(self.active)then return true;end
return nil;
end
function e:lookup(t,o,a)
self:query(t,o,a)
while self:pulse()do
local e={}
for a,t in c(self.socket)do
e[a]=t
end
s.select(e,nil,4)
end
return self:peek(t,o,a);
end
function e:lookupex(o,e,t,a)
return self:peek(e,t,a)or self:query(e,t,a);
end
function e:tohostname(e)
return t.lookup(e:gsub("(%d+)%.(%d+)%.(%d+)%.(%d+)","%4.%3.%2.%1.in-addr.arpa."),"PTR");
end
local i={
qr={[0]='query','response'},
opcode={[0]='query','inverse query','server status request'},
aa={[0]='non-authoritative','authoritative'},
tc={[0]='complete','truncated'},
rd={[0]='recursion not desired','recursion desired'},
ra={[0]='recursion not available','recursion available'},
z={[0]='(reserved)'},
rcode={[0]='no error','format error','server failure','name error','not implemented'},
type=t.type,
class=t.class
};
local function n(t,e)
return(i[e]and i[e][t[e]])or'';
end
function e.print(e)
for o,t in o{'id','qr','opcode','aa','tc','rd','ra','z',
'rcode','qdcount','ancount','nscount','arcount'}do
f(a.format('%-30s','header.'..t),e.header[t],n(e.header,t));
end
for t,e in c(e.question)do
f(a.format('question[%i].name         ',t),e.name);
f(a.format('question[%i].type         ',t),e.type);
f(a.format('question[%i].class        ',t),e.class);
end
local h={name=1,type=1,class=1,ttl=1,rdlength=1,rdata=1};
local t;
for s,i in o({'answer','authority','additional'})do
for s,e in o(e[i])do
for h,o in o({'name','type','class','ttl','rdlength'})do
t=a.format('%s[%i].%s',i,s,o);
f(a.format('%-30s',t),e[o],n(e,o));
end
for e,o in o(e)do
if not h[e]then
t=a.format('%s[%i].%s',i,s,e);
f(a.format('%-30s  %s',p(t),p(o)));
end
end
end
end
end
function t.resolver()
local t={active={},cache={},unsorted={},wanted={},best_server=1};
r(t,e);
r(t.cache,w);
r(t.unsorted,{__mode='kv'});
return t;
end
local e=t.resolver();
t._resolver=e;
function t.lookup(...)
return e:lookup(...);
end
function t.tohostname(...)
return e:tohostname(...);
end
function t.purge(...)
return e:purge(...);
end
function t.peek(...)
return e:peek(...);
end
function t.query(...)
return e:query(...);
end
function t.feed(...)
return e:feed(...);
end
function t.cancel(...)
return e:cancel(...);
end
function t.settimeout(...)
return e:settimeout(...);
end
function t.cache()
return e.cache;
end
function t.socket_wrapper_set(...)
return e:socket_wrapper_set(...);
end
return t;
end)
package.preload['net.adns']=(function(...)
local c=require"net.server";
local a=require"net.dns";
local e=require"util.logger".init("adns");
local t,t=table.insert,table.remove;
local o,r,l=coroutine,tostring,pcall;
local function u(a,a,e,t)return(t-e)+1;end
module"adns"
function lookup(d,t,h,s)
return o.wrap(function(i)
if i then
e("debug","Records for %s already cached, using those...",t);
d(i);
return;
end
e("debug","Records for %s not in cache, sending query (%s)...",t,r(o.running()));
local i,n=a.query(t,h,s);
if i then
o.yield({s or"IN",h or"A",t,o.running()});
e("debug","Reply for %s (%s)",t,r(o.running()));
end
if i then
i,n=l(d,a.peek(t,h,s));
else
e("error","Error sending DNS query: %s",n);
i,n=l(d,nil,n);
end
if not i then
e("error","Error in DNS response handler: %s",r(n));
end
end)(a.peek(t,h,s));
end
function cancel(t,o,i)
e("warn","Cancelling DNS lookup for %s",r(t[3]));
a.cancel(t[1],t[2],t[3],t[4],o);
end
function new_async_socket(o,i)
local n="<unknown>";
local s={};
local t={};
local h;
function s.onincoming(o,e)
if e then
a.feed(t,e);
end
end
function s.ondisconnect(a,o)
if o then
e("warn","DNS socket for %s disconnected: %s",n,o);
local t=i.server;
if i.socketset[a]==i.best_server and i.best_server==#t then
e("error","Exhausted all %d configured DNS servers, next lookup will try %s again",#t,t[1]);
end
i:servfail(a);
end
end
t,h=c.wrapclient(o,"dns",53,s);
if not t then
return nil,h;
end
t.settimeout=function()end
t.setsockname=function(e,...)return o:setsockname(...);end
t.setpeername=function(i,...)n=(...);local a,e=o:setpeername(...);i:set_send(u);return a,e;end
t.connect=function(e,...)return o:connect(...)end
t.send=function(a,t)
e("debug","Sending DNS query to %s",n);
return o:send(t);
end
return t;
end
a.socket_wrapper_set(new_async_socket);
return _M;
end)
package.preload['net.server']=(function(...)
local l=function(e)
return _G[e]
end
local M,e=require("util.logger").init("socket"),table.concat;
local i=function(...)return M("debug",e{...});end
local H=function(...)return M("warn",e{...});end
local ce=1
local F=l"type"
local W=l"pairs"
local de=l"ipairs"
local y=l"tonumber"
local h=l"tostring"
local t=l"os"
local o=l"table"
local a=l"string"
local e=l"coroutine"
local Z=t.difftime
local X=math.min
local re=math.huge
local fe=o.concat
local me=a.sub
local we=e.wrap
local ye=e.yield
local x=l"ssl"
local b=l"socket"or require"socket"
local J=b.gettime
local ve=(x and x.wrap)
local he=b.bind
local pe=b.sleep
local be=b.select
local G
local B
local ae
local K
local te
local c
local ee
local oe
local ne
local ie
local se
local Q
local r
local le
local D
local ue
local p
local s
local R
local d
local n
local S
local g
local f
local m
local a
local o
local v
local U
local C
local T
local E
local k
local V
local u
local _
local z
local A
local I
local O
local L
local j
local q
local N
p={}
s={}
d={}
R={}
n={}
g={}
f={}
S={}
a=0
o=0
v=0
U=0
C=0
T=1
E=0
k=128
_=51e3*1024
z=25e3*1024
A=12e5
I=6e4
O=6*60*60
local e=package.config:sub(1,1)=="\\"
q=(e and math.huge)or b._SETSIZE or 1024
j=b._SETSIZE or 1024
N=30
ie=function(w,t,f,l,v,u)
if t:getfd()>=q then
H("server.lua: Disallowed FD number: "..t:getfd())
t:close()
return nil,"fd-too-large"
end
local m=0
local y,e=w.onconnect,w.ondisconnect
local b=t.accept
local e={}
e.shutdown=function()end
e.ssl=function()
return u~=nil
end
e.sslctx=function()
return u
end
e.remove=function()
m=m-1
if e then
e.resume()
end
end
e.close=function()
t:close()
o=r(d,t,o)
a=r(s,t,a)
p[f..":"..l]=nil;
n[t]=nil
e=nil
t=nil
i"server.lua: closed server handler and removed sockets from list"
end
e.pause=function(o)
if not e.paused then
a=r(s,t,a)
if o then
n[t]=nil
t:close()
t=nil;
end
e.paused=true;
end
end
e.resume=function()
if e.paused then
if not t then
t=he(f,l,k);
t:settimeout(0)
end
a=c(s,t,a)
n[t]=e
e.paused=false;
end
end
e.ip=function()
return f
end
e.serverport=function()
return l
end
e.socket=function()
return t
end
e.readbuffer=function()
if a>=j or o>=j then
e.pause()
i("server.lua: refused new client connection: server full")
return false
end
local t,o=b(t)
if t then
local o,a=t:getpeername()
local t,n,e=D(e,w,t,o,l,a,v,u)
if e then
return false
end
m=m+1
i("server.lua: accepted new client connection from ",h(o),":",h(a)," to ",h(l))
if y and not u then
return y(t);
end
return;
elseif o then
i("server.lua: error with new client connection: ",h(o))
return false
end
end
return e
end
D=function(E,y,t,I,Q,O,T,j)
if t:getfd()>=q then
H("server.lua: Disallowed FD number: "..t:getfd())
t:close()
if E then
E.pause()
end
return nil,nil,"fd-too-large"
end
t:settimeout(0)
local p
local A
local k
local P
local W=y.onincoming
local Y=y.onstatus
local b=y.ondisconnect
local F=y.ondrain
local M=y.ondetach
local v={}
local l=0
local V
local B
local L
local w=0
local q=false
local H=false
local D,R=0,0
local _=_
local z=z
local e=v
e.dispatch=function()
return W
end
e.disconnect=function()
return b
end
e.setlistener=function(a,t)
if M then
M(a)
end
W=t.onincoming
b=t.ondisconnect
Y=t.onstatus
F=t.ondrain
M=t.ondetach
end
e.getstats=function()
return R,D
end
e.ssl=function()
return P
end
e.sslctx=function()
return j
end
e.send=function(n,o,i,a)
return p(t,o,i,a)
end
e.receive=function(o,a)
return A(t,o,a)
end
e.shutdown=function(a)
return k(t,a)
end
e.setoption=function(i,a,o)
if t.setoption then
return t:setoption(a,o);
end
return false,"setoption not implemented";
end
e.force_close=function(t,a)
if l~=0 then
i("server.lua: discarding unwritten data for ",h(I),":",h(O))
l=0;
end
return t:close(a);
end
e.close=function(u,h)
if not e then return true;end
a=r(s,t,a)
g[e]=nil
if l~=0 then
e.sendbuffer()
if l~=0 then
if e then
e.write=nil
end
V=true
return false
end
end
if t then
m=k and k(t)
t:close()
o=r(d,t,o)
n[t]=nil
t=nil
else
i"server.lua: socket already closed"
end
if e then
f[e]=nil
S[e]=nil
local t=e;
e=nil
if b then
b(t,h or false);
b=nil
end
end
if E then
E.remove()
end
i"server.lua: closed client handler and removed socket from list"
return true
end
e.ip=function()
return I
end
e.serverport=function()
return Q
end
e.clientport=function()
return O
end
e.port=e.clientport
local b=function(i,a)
w=w+#a
if w>_ then
S[e]="send buffer exceeded"
e.write=K
return false
elseif t and not d[t]then
o=c(d,t,o)
end
l=l+1
v[l]=a
if e then
f[e]=f[e]or u
end
return true
end
e.write=b
e.bufferqueue=function(t)
return v
end
e.socket=function(a)
return t
end
e.set_mode=function(a,t)
T=t or T
return T
end
e.set_send=function(a,t)
p=t or p
return p
end
e.bufferlen=function(o,a,t)
_=t or _
z=a or z
return w,z,_
end
e.lock_read=function(i,o)
if o==true then
local o=a
a=r(s,t,a)
g[e]=nil
if a~=o then
q=true
end
elseif o==false then
if q then
q=false
a=c(s,t,a)
g[e]=u
end
end
return q
end
e.pause=function(t)
return t:lock_read(true);
end
e.resume=function(t)
return t:lock_read(false);
end
e.lock=function(i,a)
e.lock_read(a)
if a==true then
e.write=K
local a=o
o=r(d,t,o)
f[e]=nil
if o~=a then
H=true
end
elseif a==false then
e.write=b
if H then
H=false
b("")
end
end
return q,H
end
local b=function()
local a,t,o=A(t,T)
if not t or(t=="wantread"or t=="timeout")then
local o=a or o or""
local a=#o
if a>z then
e:close("receive buffer exceeded")
return false
end
local a=a*ce
R=R+a
C=C+a
g[e]=u
return W(e,o,t)
else
i("server.lua: client ",h(I),":",h(O)," read error: ",h(t))
B=true
m=e and e:force_close(t)
return false
end
end
local w=function()
local c,a,n,s,y;
if t then
s=fe(v,"",1,l)
c,a,n=p(t,s,1,w)
y=(c or n or 0)*ce
D=D+y
U=U+y
for e=l,1,-1 do
v[e]=nil
end
else
c,a,y=false,"unexpected close",0;
end
if c then
l=0
w=0
o=r(d,t,o)
f[e]=nil
if F then
F(e)
end
m=L and e:starttls(nil)
m=V and e:force_close()
return true
elseif n and(a=="timeout"or a=="wantwrite")then
s=me(s,n+1,w)
v[1]=s
l=1
w=w-n
f[e]=u
return true
else
i("server.lua: client ",h(I),":",h(O)," write error: ",h(a))
B=true
m=e and e:force_close(a)
return false
end
end
local u;
function e.set_sslctx(p,t)
j=t;
local l,f
u=we(function(n)
local t
for h=1,N do
o=(f and r(d,n,o))or o
a=(l and r(s,n,a))or a
l,f=nil,nil
m,t=n:dohandshake()
if not t then
i("server.lua: ssl handshake done")
e.readbuffer=b
e.sendbuffer=w
m=Y and Y(e,"ssl-handshake-complete")
if p.autostart_ssl and y.onconnect then
y.onconnect(p);
end
a=c(s,n,a)
return true
else
if t=="wantwrite"then
o=c(d,n,o)
f=true
elseif t=="wantread"then
a=c(s,n,a)
l=true
else
break;
end
t=nil;
ye()
end
end
i("server.lua: ssl handshake error: ",h(t or"handshake too long"))
m=e and e:force_close("ssl handshake failed")
return false,t
end
)
end
if x then
e.starttls=function(f,m)
if m then
e:set_sslctx(m);
end
if l>0 then
i"server.lua: we need to do tls, but delaying until send buffer empty"
L=true
return
end
i("server.lua: attempting to start tls on "..h(t))
local m,l=t
t,l=ve(t,j)
if not t then
i("server.lua: error while starting tls on client: ",h(l or"unknown error"))
return nil,l
end
t:settimeout(0)
p=t.send
A=t.receive
k=G
n[t]=e
a=c(s,t,a)
a=r(s,m,a)
o=r(d,m,o)
n[m]=nil
e.starttls=nil
L=nil
P=true
e.readbuffer=u
e.sendbuffer=u
return u(t)
end
end
e.readbuffer=b
e.sendbuffer=w
p=t.send
A=t.receive
k=(P and G)or t.shutdown
n[t]=e
a=c(s,t,a)
if j and x then
i"server.lua: auto-starting ssl negotiation..."
e.autostart_ssl=true;
local t,e=e:starttls(j);
if t==false then
return nil,nil,e
end
end
return e,t
end
G=function()
end
K=function()
return false
end
c=function(t,a,e)
if not t[a]then
e=e+1
t[e]=a
t[a]=e
end
return e;
end
r=function(e,a,t)
local o=e[a]
if o then
e[a]=nil
local i=e[t]
e[t]=nil
if i~=a then
e[i]=o
e[o]=i
end
return t-1
end
return t
end
Q=function(e)
o=r(d,e,o)
a=r(s,e,a)
n[e]=nil
e:close()
end
local function w(e,a,o)
local t;
local i=a.sendbuffer;
function a.sendbuffer()
i();
if t and a.bufferlen()<o then
e:lock_read(false);
t=nil;
end
end
local i=e.readbuffer;
function e.readbuffer()
i();
if not t and a.bufferlen()>=o then
t=true;
e:lock_read(true);
end
end
e:set_mode("*a");
end
ee=function(t,e,d,l,r)
local o
if F(d)~="table"then
o="invalid listener table"
end
if F(e)~="number"or not(e>=0 and e<=65535)then
o="invalid port"
elseif p[t..":"..e]then
o="listeners on '["..t.."]:"..e.."' already exist"
elseif r and not x then
o="luasec not found"
end
if o then
H("server.lua, [",t,"]:",e,": ",o)
return nil,o
end
t=t or"*"
local o,h=he(t,e,k)
if h then
H("server.lua, [",t,"]:",e,": ",h)
return nil,h
end
local h,d=ie(d,o,t,e,l,r)
if not h then
o:close()
return nil,d
end
o:settimeout(0)
a=c(s,o,a)
p[t..":"..e]=h
n[o]=h
i("server.lua: new "..(r and"ssl "or"").."server listener on '[",t,"]:",e,"'")
return h
end
ne=function(t,e)
return p[t..":"..e];
end
le=function(t,e)
local a=p[t..":"..e]
if not a then
return nil,"no server found on '["..t.."]:"..h(e).."'"
end
a:close()
p[t..":"..e]=nil
return true
end
te=function()
for e,t in W(n)do
t:close()
n[e]=nil
end
a=0
o=0
v=0
p={}
s={}
d={}
R={}
n={}
end
se=function()
return{
select_timeout=T;
select_sleep_time=E;
tcp_backlog=k;
max_send_buffer_size=_;
max_receive_buffer_size=z;
select_idle_check_interval=A;
send_timeout=I;
read_timeout=O;
max_connections=j;
max_ssl_handshake_roundtrips=N;
highest_allowed_fd=q;
}
end
ue=function(e)
if F(e)~="table"then
return nil,"invalid settings table"
end
T=y(e.select_timeout)or T
E=y(e.select_sleep_time)or E
_=y(e.max_send_buffer_size)or _
z=y(e.max_receive_buffer_size)or z
A=y(e.select_idle_check_interval)or A
k=y(e.tcp_backlog)or k
I=y(e.send_timeout)or I
O=y(e.read_timeout)or O
j=e.max_connections or j
N=e.max_ssl_handshake_roundtrips or N
q=e.highest_allowed_fd or q
return true
end
oe=function(e)
if F(e)~="function"then
return nil,"invalid listener function"
end
v=v+1
R[v]=e
return true
end
ae=function()
return C,U,a,o,v
end
local t;
local function h(e)
t=not not e;
end
B=function(a)
if t then return"quitting";end
if a then t="once";end
local e=re;
repeat
local o,a,s=be(s,d,X(T,e))
for t,e in de(a)do
local t=n[e]
if t then
t.sendbuffer()
else
Q(e)
i"server.lua: found no handler and closed socket (writelist)"
end
end
for e,t in de(o)do
local e=n[t]
if e then
e.readbuffer()
else
Q(t)
i"server.lua: found no handler and closed socket (readlist)"
end
end
for e,t in W(S)do
e.disconnect()(e,t)
e:force_close()
S[e]=nil;
end
u=J()
local a=Z(u-V)
if a>A then
V=u
for e,t in W(f)do
if Z(u-t)>I then
e.disconnect()(e,"send timeout")
e:force_close()
end
end
for e,t in W(g)do
if Z(u-t)>O then
e.disconnect()(e,"read timeout")
e:close()
end
end
end
if u-L>=X(e,1)then
e=re;
for t=1,v do
local t=R[t](u)
if t then e=X(e,t);end
end
L=u
else
e=e-(u-L);
end
pe(E)
until t;
if a and t=="once"then t=nil;return;end
return"quitting"
end
local function u()
return B(true);
end
local function r()
return"select";
end
local i=function(e,t,s,a,h,i)
local e,t,s=D(nil,a,e,t,s,"clientport",h,i)
if not e then return nil,s end
n[t]=e
if not i then
o=c(d,t,o)
if a.onconnect then
local t=e.sendbuffer;
e.sendbuffer=function()
e.sendbuffer=t;
a.onconnect(e);
return t();
end
end
end
return e,t
end
local o=function(a,o,n,h,s)
local e,t=b.tcp()
if t then
return nil,t
end
e:settimeout(0)
m,t=e:connect(a,o)
if t then
local e=i(e,a,o,n)
else
D(nil,n,e,a,o,"clientport",h,s)
end
end
l"setmetatable"(n,{__mode="k"})
l"setmetatable"(g,{__mode="k"})
l"setmetatable"(f,{__mode="k"})
L=J()
V=J()
local function a(e)
local t=M;
if e then
M=e;
end
return t;
end
return{
_addtimer=oe,
addclient=o,
wrapclient=i,
loop=B,
link=w,
step=u,
stats=ae,
closeall=te,
addserver=ee,
getserver=ne,
setlogger=a,
getsettings=se,
setquitting=h,
removeserver=le,
get_backend=r,
changesettings=ue,
}
end)
package.preload['util.xmppstream']=(function(...)
local e=require"lxp";
local t=require"util.stanza";
local b=t.stanza_mt;
local f=error;
local t=tostring;
local l=table.insert;
local y=table.concat;
local x=table.remove;
local v=setmetatable;
local j=pcall(e.new,{StartDoctypeDecl=false});
local k=pcall(e.new,{XmlDecl=false});
local a=not not e.new({}).getcurrentbytecount;
local q=1024*1024*10;
module"xmppstream"
local p=e.new;
local z={
["http://www.w3.org/XML/1998/namespace\1lang"]="xml:lang";
["http://www.w3.org/XML/1998/namespace\1space"]="xml:space";
["http://www.w3.org/XML/1998/namespace\1base"]="xml:base";
["http://www.w3.org/XML/1998/namespace\1id"]="xml:id";
};
local h="http://etherx.jabber.org/streams";
local d="\1";
local g="^([^"..d.."]*)"..d.."?(.*)$";
_M.ns_separator=d;
_M.ns_pattern=g;
local function o()end
function new_sax_handlers(n,e,s)
local i={};
local p=e.streamopened;
local w=e.streamclosed;
local u=e.error or function(o,a,e)f("XML stream error: "..t(a)..(e and": "..t(e)or""),2);end;
local q=e.handlestanza;
s=s or o;
local t=e.stream_ns or h;
local m=e.stream_tag or"stream";
if t~=""then
m=t..d..m;
end
local _=t..d..(e.error_tag or"error");
local E=e.default_ns;
local d={};
local h,e={};
local t=0;
local r=0;
function i:StartElement(c,o)
if e and#h>0 then
l(e,y(h));
h={};
end
local h,i=c:match(g);
if i==""then
h,i="",h;
end
if h~=E or r>0 then
o.xmlns=h;
r=r+1;
end
for t=1,#o do
local e=o[t];
o[t]=nil;
local t=z[e];
if t then
o[t]=o[e];
o[e]=nil;
end
end
if not e then
if a then
t=self:getcurrentbytecount();
end
if n.notopen then
if c==m then
r=0;
if p then
if a then
s(t);
t=0;
end
p(n,o);
end
else
u(n,"no-stream",c);
end
return;
end
if h=="jabber:client"and i~="iq"and i~="presence"and i~="message"then
u(n,"invalid-top-level-element");
end
e=v({name=i,attr=o,tags={}},b);
else
if a then
t=t+self:getcurrentbytecount();
end
l(d,e);
local t=e;
e=v({name=i,attr=o,tags={}},b);
l(t,e);
l(t.tags,e);
end
end
if k then
function i:XmlDecl(e,e,e)
if a then
s(self:getcurrentbytecount());
end
end
end
function i:StartCdataSection()
if a then
if e then
t=t+self:getcurrentbytecount();
else
s(self:getcurrentbytecount());
end
end
end
function i:EndCdataSection()
if a then
if e then
t=t+self:getcurrentbytecount();
else
s(self:getcurrentbytecount());
end
end
end
function i:CharacterData(o)
if e then
if a then
t=t+self:getcurrentbytecount();
end
l(h,o);
elseif a then
s(self:getcurrentbytecount());
end
end
function i:EndElement(o)
if a then
t=t+self:getcurrentbytecount()
end
if r>0 then
r=r-1;
end
if e then
if#h>0 then
l(e,y(h));
h={};
end
if#d==0 then
if a then
s(t);
end
t=0;
if o~=_ then
q(n,e);
else
u(n,"stream-error",e);
end
e=nil;
else
e=x(d);
end
else
if w then
w(n);
end
end
end
local function a(e)
u(n,"parse-error","restricted-xml","Restricted XML, see RFC 6120 section 11.1.");
if not e.stop or not e:stop()then
f("Failed to abort parsing");
end
end
if j then
i.StartDoctypeDecl=a;
end
i.Comment=a;
i.ProcessingInstruction=a;
local function a()
e,h,t=nil,{},0;
d={};
end
local function e(t,e)
n=e;
end
return i,{reset=a,set_session=e};
end
function new(n,i,o)
local e=0;
local t;
if a then
function t(t)
e=e-t;
end
o=o or q;
elseif o then
f("Stanza size limits are not supported on this version of LuaExpat")
end
local i,n=new_sax_handlers(n,i,t);
local t=p(i,d,false);
local s=t.parse;
return{
reset=function()
t=p(i,d,false);
s=t.parse;
e=0;
n.reset();
end,
feed=function(n,i)
if a then
e=e+#i;
end
local i,t=s(t,i);
if a and e>o then
return nil,"stanza-too-large";
end
return i,t;
end,
set_session=n.set_session;
};
end
return _M;
end)
package.preload['util.jid']=(function(...)
local t,i=string.match,string.sub;
local d=require"util.encodings".stringprep.nodeprep;
local r=require"util.encodings".stringprep.nameprep;
local h=require"util.encodings".stringprep.resourceprep;
local n={
[" "]="\\20";['"']="\\22";
["&"]="\\26";["'"]="\\27";
["/"]="\\2f";[":"]="\\3a";
["<"]="\\3c";[">"]="\\3e";
["@"]="\\40";["\\"]="\\5c";
};
local s={};
for t,e in pairs(n)do s[e]=t;end
module"jid"
local function a(e)
if not e then return;end
local i,a=t(e,"^([^@/]+)@()");
local a,o=t(e,"^([^@/]+)()",a)
if i and not a then return nil,nil,nil;end
local t=t(e,"^/(.+)$",o);
if(not a)or((not t)and#e>=o)then return nil,nil,nil;end
return i,a,t;
end
split=a;
function bare(e)
local t,e=a(e);
if t and e then
return t.."@"..e;
end
return e;
end
local function o(e)
local a,e,t=a(e);
if e then
if i(e,-1,-1)=="."then
e=i(e,1,-2);
end
e=r(e);
if not e then return;end
if a then
a=d(a);
if not a then return;end
end
if t then
t=h(t);
if not t then return;end
end
return a,e,t;
end
end
prepped_split=o;
function prep(e)
local t,e,a=o(e);
if e then
if t then
e=t.."@"..e;
end
if a then
e=e.."/"..a;
end
end
return e;
end
function join(t,e,a)
if t and e and a then
return t.."@"..e.."/"..a;
elseif t and e then
return t.."@"..e;
elseif e and a then
return e.."/"..a;
elseif e then
return e;
end
return nil;
end
function compare(e,t)
local o,i,n=a(e);
local e,t,a=a(t);
if((e~=nil and e==o)or e==nil)and
((t~=nil and t==i)or t==nil)and
((a~=nil and a==n)or a==nil)then
return true
end
return false
end
function escape(e)return e and(e:gsub(".",n));end
function unescape(e)return e and(e:gsub("\\%x%x",s));end
return _M;
end)
package.preload['util.events']=(function(...)
local i=pairs;
local s=table.insert;
local o=table.sort;
local d=setmetatable;
local n=next;
module"events"
function new()
local t={};
local e={};
local function r(h,a)
local e=e[a];
if not e or n(e)==nil then return;end
local t={};
for e in i(e)do
s(t,e);
end
o(t,function(t,a)return e[t]>e[a];end);
h[a]=t;
return t;
end;
d(t,{__index=r});
local function s(o,i,n)
local a=e[o];
if a then
a[i]=n or 0;
else
a={[i]=n or 0};
e[o]=a;
end
t[o]=nil;
end;
local function h(a,i)
local o=e[a];
if o then
o[i]=nil;
t[a]=nil;
if n(o)==nil then
e[a]=nil;
end
end
end;
local function n(e)
for e,t in i(e)do
s(e,t);
end
end;
local function o(e)
for t,e in i(e)do
h(t,e);
end
end;
local function a(e,...)
local e=t[e];
if e then
for t=1,#e do
local e=e[t](...);
if e~=nil then return e;end
end
end
end;
return{
add_handler=s;
remove_handler=h;
add_handlers=n;
remove_handlers=o;
fire_event=a;
_handlers=t;
_event_map=e;
};
end
return _M;
end)
package.preload['util.dataforms']=(function(...)
local a=setmetatable;
local e,i=pairs,ipairs;
local r,h,l=tostring,type,next;
local n=table.concat;
local c=require"util.stanza";
local d=require"util.jid".prep;
module"dataforms"
local u='jabber:x:data';
local s={};
local e={__index=s};
function new(t)
return a(t,e);
end
function from_stanza(e)
local o={
title=e:get_child_text("title");
instructions=e:get_child_text("instructions");
};
for e in e:childtags("field")do
local a={
name=e.attr.var;
label=e.attr.label;
type=e.attr.type;
required=e:get_child("required")and true or nil;
value=e:get_child_text("value");
};
o[#o+1]=a;
if a.type then
local t={};
if a.type:match"list%-"then
for e in e:childtags("option")do
t[#t+1]={label=e.attr.label,value=e:get_child_text("value")};
end
for e in e:childtags("value")do
t[#t+1]={label=e.attr.label,value=e:get_text(),default=true};
end
elseif a.type:match"%-multi"then
for e in e:childtags("value")do
t[#t+1]=e.attr.label and{label=e.attr.label,value=e:get_text()}or e:get_text();
end
if a.type=="text-multi"then
a.value=n(t,"\n");
else
a.value=t;
end
end
end
end
return new(o);
end
function s.form(t,a,e)
local e=c.stanza("x",{xmlns=u,type=e or"form"});
if t.title then
e:tag("title"):text(t.title):up();
end
if t.instructions then
e:tag("instructions"):text(t.instructions):up();
end
for t,o in i(t)do
local t=o.type or"text-single";
e:tag("field",{type=t,var=o.name,label=o.label});
local a=(a and a[o.name])or o.value;
if a then
if t=="hidden"then
if h(a)=="table"then
e:tag("value")
:add_child(a)
:up();
else
e:tag("value"):text(r(a)):up();
end
elseif t=="boolean"then
e:tag("value"):text((a and"1")or"0"):up();
elseif t=="fixed"then
elseif t=="jid-multi"then
for a,t in i(a)do
e:tag("value"):text(t):up();
end
elseif t=="jid-single"then
e:tag("value"):text(a):up();
elseif t=="text-single"or t=="text-private"then
e:tag("value"):text(a):up();
elseif t=="text-multi"then
for t in a:gmatch("([^\r\n]+)\r?\n*")do
e:tag("value"):text(t):up();
end
elseif t=="list-single"then
local o=false;
for a,t in i(a)do
if h(t)=="table"then
e:tag("option",{label=t.label}):tag("value"):text(t.value):up():up();
if t.default and(not o)then
e:tag("value"):text(t.value):up();
o=true;
end
else
e:tag("option",{label=t}):tag("value"):text(r(t)):up():up();
end
end
elseif t=="list-multi"then
for a,t in i(a)do
if h(t)=="table"then
e:tag("option",{label=t.label}):tag("value"):text(t.value):up():up();
if t.default then
e:tag("value"):text(t.value):up();
end
else
e:tag("option",{label=t}):tag("value"):text(r(t)):up():up();
end
end
end
end
if o.required then
e:tag("required"):up();
end
e:up();
end
return e;
end
local e={};
function s.data(t,n)
local o={};
local a={};
for i,t in i(t)do
local i;
for e in n:childtags()do
if t.name==e.attr.var then
i=e;
break;
end
end
if not i then
if t.required then
a[t.name]="Required value missing";
end
else
local e=e[t.type];
if e then
o[t.name],a[t.name]=e(i,t.required);
end
end
end
if l(a)then
return o,a;
end
return o;
end
e["text-single"]=
function(t,a)
local t=t:get_child_text("value");
if t and#t>0 then
return t
elseif a then
return nil,"Required value missing";
end
end
e["text-private"]=
e["text-single"];
e["jid-single"]=
function(t,o)
local a=t:get_child_text("value")
local t=d(a);
if t and#t>0 then
return t
elseif a then
return nil,"Invalid JID: "..a;
elseif o then
return nil,"Required value missing";
end
end
e["jid-multi"]=
function(o,i)
local t={};
local a={};
for e in o:childtags("value")do
local e=e:get_text();
local o=d(e);
t[#t+1]=o;
if e and not o then
a[#a+1]=("Invalid JID: "..e);
end
end
if#t>0 then
return t,(#a>0 and n(a,"\n")or nil);
elseif i then
return nil,"Required value missing";
end
end
e["list-multi"]=
function(o,a)
local t={};
for e in o:childtags("value")do
t[#t+1]=e:get_text();
end
return t,(a and#t==0 and"Required value missing"or nil);
end
e["text-multi"]=
function(a,t)
local t,a=e["list-multi"](a,t);
if t then
t=n(t,"\n");
end
return t,a;
end
e["list-single"]=
e["text-single"];
local a={
["1"]=true,["true"]=true,
["0"]=false,["false"]=false,
};
e["boolean"]=
function(t,o)
local t=t:get_child_text("value");
local a=a[t~=nil and t];
if a~=nil then
return a;
elseif t then
return nil,"Invalid boolean representation";
elseif o then
return nil,"Required value missing";
end
end
e["hidden"]=
function(e)
return e:get_child_text("value");
end
return _M;
end)
package.preload['util.caps']=(function(...)
local l=require"util.encodings".base64.encode;
local d=require"util.hashes".sha1;
local n,s,h=table.insert,table.sort,table.concat;
local r=ipairs;
module"caps"
function calculate_hash(e)
local i,o,a={},{},{};
for t,e in r(e)do
if e.name=="identity"then
n(i,(e.attr.category or"").."\0"..(e.attr.type or"").."\0"..(e.attr["xml:lang"]or"").."\0"..(e.attr.name or""));
elseif e.name=="feature"then
n(o,e.attr.var or"");
elseif e.name=="x"and e.attr.xmlns=="jabber:x:data"then
local t={};
local o;
for a,e in r(e.tags)do
if e.name=="field"and e.attr.var then
local a={};
for t,e in r(e.tags)do
e=#e.tags==0 and e:get_text();
if e then n(a,e);end
end
s(a);
if e.attr.var=="FORM_TYPE"then
o=a[1];
elseif#a>0 then
n(t,e.attr.var.."\0"..h(a,"<"));
else
n(t,e.attr.var);
end
end
end
s(t);
t=h(t,"<");
if o then t=o.."\0"..t;end
n(a,t);
end
end
s(i);
s(o);
s(a);
if#i>0 then i=h(i,"<"):gsub("%z","/").."<";else i="";end
if#o>0 then o=h(o,"<").."<";else o="";end
if#a>0 then a=h(a,"<"):gsub("%z","<").."<";else a="";end
local e=i..o..a;
local t=l(d(e));
return t,e;
end
return _M;
end)
package.preload['util.vcard']=(function(...)
local i=require"util.stanza";
local a,r=table.insert,table.concat;
local s=type;
local e,n,c=next,pairs,ipairs;
local d,h,l,u;
local f="\n";
local o;
local function e()
error"Not implemented"
end
local function e()
error"Not implemented"
end
local function w(e)
return e:gsub("[,:;\\]","\\%1"):gsub("\n","\\n");
end
local function y(e)
return e:gsub("\\?[\\nt:;,]",{
["\\\\"]="\\",
["\\n"]="\n",
["\\r"]="\r",
["\\t"]="\t",
["\\:"]=":",
["\\;"]=";",
["\\,"]=",",
[":"]="\29",
[";"]="\30",
[","]="\31",
});
end
local function p(e)
local a=i.stanza(e.name,{xmlns="vcard-temp"});
local t=o[e.name];
if t=="text"then
a:text(e[1]);
elseif s(t)=="table"then
if t.types and e.TYPE then
if s(e.TYPE)=="table"then
for o,t in n(t.types)do
for o,e in n(e.TYPE)do
if e:upper()==t then
a:tag(t):up();
break;
end
end
end
else
a:tag(e.TYPE:upper()):up();
end
end
if t.props then
for o,t in n(t.props)do
if e[t]then
a:tag(t):up();
end
end
end
if t.value then
a:tag(t.value):text(e[1]):up();
elseif t.values then
local o=t.values;
local i=o.behaviour=="repeat-last"and o[#o];
for o=1,#e do
a:tag(t.values[o]or i):text(e[o]):up();
end
end
end
return a;
end
local function m(t)
local e=i.stanza("vCard",{xmlns="vcard-temp"});
for a=1,#t do
e:add_child(p(t[a]));
end
return e;
end
function u(e)
if not e[1]or e[1].name then
return m(e)
else
local t=i.stanza("xCard",{xmlns="vcard-temp"});
for a=1,#e do
t:add_child(m(e[a]));
end
return t;
end
end
function d(t)
t=t
:gsub("\r\n","\n")
:gsub("\n ","")
:gsub("\n\n+","\n");
local s={};
local e;
for t in t:gmatch("[^\n]+")do
local t=y(t);
local n,t,i=t:match("^([-%a]+)(\30?[^\29]*)\29(.*)$");
i=i:gsub("\29",":");
if#t>0 then
local o={};
for a,n,i in t:gmatch("\30([^=]+)(=?)([^\30]*)")do
a=a:upper();
local e={};
for t in i:gmatch("[^\31]+")do
e[#e+1]=t
e[t]=true;
end
if n=="="then
o[a]=e;
else
o[a]=true;
end
end
t=o;
end
if n=="BEGIN"and i=="VCARD"then
e={};
s[#s+1]=e;
elseif n=="END"and i=="VCARD"then
e=nil;
elseif e and o[n]then
local o=o[n];
local n={name=n};
e[#e+1]=n;
local s=e;
e=n;
if o.types then
for o,a in c(o.types)do
local a=a:lower();
if(t.TYPE and t.TYPE[a]==true)
or t[a]==true then
e.TYPE=a;
end
end
end
if o.props then
for o,a in c(o.props)do
if t[a]then
if t[a]==true then
e[a]=true;
else
for o,t in c(t[a])do
e[a]=t;
end
end
end
end
end
if o=="text"or o.value then
a(e,i);
elseif o.values then
local t="\30"..i;
for t in t:gmatch("\30([^\30]*)")do
a(e,t);
end
end
e=s;
end
end
return s;
end
local function c(t)
local e={};
for a=1,#t do
e[a]=w(t[a]);
end
e=r(e,";");
local a="";
for e,t in n(t)do
if s(e)=="string"and e~="name"then
a=a..(";%s=%s"):format(e,s(t)=="table"and r(t,",")or t);
end
end
return("%s%s:%s"):format(t.name,a,e)
end
local function i(t)
local e={};
a(e,"BEGIN:VCARD")
for o=1,#t do
a(e,c(t[o]));
end
a(e,"END:VCARD")
return r(e,f);
end
function h(e)
if e[1]and e[1].name then
return i(e)
else
local t={};
for a=1,#e do
t[a]=i(e[a]);
end
return r(t,f);
end
end
local function r(i)
local e=i.name;
local t=o[e];
local e={name=e};
if t=="text"then
e[1]=i:get_text();
elseif s(t)=="table"then
if t.value then
e[1]=i:get_child_text(t.value)or"";
elseif t.values then
local t=t.values;
if t.behaviour=="repeat-last"then
for t=1,#i.tags do
a(e,i.tags[t]:get_text()or"");
end
else
for o=1,#t do
a(e,i:get_child_text(t[o])or"");
end
end
elseif t.names then
local t=t.names;
for a=1,#t do
if i:get_child(t[a])then
e[1]=t[a];
break;
end
end
end
if t.props_verbatim then
for a,t in n(t.props_verbatim)do
e[a]=t;
end
end
if t.types then
local t=t.types;
e.TYPE={};
for o=1,#t do
if i:get_child(t[o])then
a(e.TYPE,t[o]:lower());
end
end
if#e.TYPE==0 then
e.TYPE=nil;
end
end
if t.props then
local t=t.props;
for o=1,#t do
local t=t[o]
local o=i:get_child_text(t);
if o then
e[t]=e[t]or{};
a(e[t],o);
end
end
end
else
return nil
end
return e;
end
local function i(e)
local e=e.tags;
local t={};
for o=1,#e do
a(t,r(e[o]));
end
return t
end
function l(e)
if e.attr.xmlns~="vcard-temp"then
return nil,"wrong-xmlns";
end
if e.name=="xCard"then
local t={};
local a=e.tags;
for e=1,#a do
t[e]=i(a[e]);
end
return t
elseif e.name=="vCard"then
return i(e)
end
end
o={
VERSION="text",
FN="text",
N={
values={
"FAMILY",
"GIVEN",
"MIDDLE",
"PREFIX",
"SUFFIX",
},
},
NICKNAME="text",
PHOTO={
props_verbatim={ENCODING={"b"}},
props={"TYPE"},
value="BINVAL",
},
BDAY="text",
ADR={
types={
"HOME",
"WORK",
"POSTAL",
"PARCEL",
"DOM",
"INTL",
"PREF",
},
values={
"POBOX",
"EXTADD",
"STREET",
"LOCALITY",
"REGION",
"PCODE",
"CTRY",
}
},
LABEL={
types={
"HOME",
"WORK",
"POSTAL",
"PARCEL",
"DOM",
"INTL",
"PREF",
},
value="LINE",
},
TEL={
types={
"HOME",
"WORK",
"VOICE",
"FAX",
"PAGER",
"MSG",
"CELL",
"VIDEO",
"BBS",
"MODEM",
"ISDN",
"PCS",
"PREF",
},
value="NUMBER",
},
EMAIL={
types={
"HOME",
"WORK",
"INTERNET",
"PREF",
"X400",
},
value="USERID",
},
JABBERID="text",
MAILER="text",
TZ="text",
GEO={
values={
"LAT",
"LON",
},
},
TITLE="text",
ROLE="text",
LOGO="copy of PHOTO",
AGENT="text",
ORG={
values={
behaviour="repeat-last",
"ORGNAME",
"ORGUNIT",
}
},
CATEGORIES={
values="KEYWORD",
},
NOTE="text",
PRODID="text",
REV="text",
SORTSTRING="text",
SOUND="copy of PHOTO",
UID="text",
URL="text",
CLASS={
names={
"PUBLIC",
"PRIVATE",
"CONFIDENTIAL",
},
},
KEY={
props={"TYPE"},
value="CRED",
},
DESC="text",
};
o.LOGO=o.PHOTO;
o.SOUND=o.PHOTO;
return{
from_text=d;
to_text=h;
from_xep54=l;
to_xep54=u;
lua_to_text=h;
lua_to_xep54=u;
text_to_lua=d;
text_to_xep54=function(...)return u(d(...));end;
xep54_to_lua=l;
xep54_to_text=function(...)return h(l(...))end;
};
end)
package.preload['util.logger']=(function(...)
local e=pcall;
local e=string.find;
local e,n,e=ipairs,pairs,setmetatable;
module"logger"
local e={};
local t;
function init(e)
local a=t(e,"debug");
local i=t(e,"info");
local o=t(e,"warn");
local n=t(e,"error");
return function(e,t,...)
if e=="debug"then
return a(t,...);
elseif e=="info"then
return i(t,...);
elseif e=="warn"then
return o(t,...);
elseif e=="error"then
return n(t,...);
end
end
end
function t(i,a)
local t=e[a];
if not t then
t={};
e[a]=t;
end
local e=function(o,...)
for e=1,#t do
t[e](i,a,o,...);
end
end
return e;
end
function reset()
for t,e in n(e)do
for t=1,#e do
e[t]=nil;
end
end
end
function add_level_sink(t,a)
if not e[t]then
e[t]={a};
else
e[t][#e[t]+1]=a;
end
end
_M.new=t;
return _M;
end)
package.preload['util.datetime']=(function(...)
local e=os.date;
local i=os.time;
local u=os.difftime;
local t=error;
local l=tonumber;
module"datetime"
function date(t)
return e("!%Y-%m-%d",t);
end
function datetime(t)
return e("!%Y-%m-%dT%H:%M:%SZ",t);
end
function time(t)
return e("!%H:%M:%S",t);
end
function legacy(t)
return e("!%Y%m%dT%H:%M:%S",t);
end
function parse(t)
if t then
local n,r,s,h,d,a,o;
n,r,s,h,d,a,o=t:match("^(%d%d%d%d)%-?(%d%d)%-?(%d%d)T(%d%d):(%d%d):(%d%d)%.?%d*([Z+%-]?.*)$");
if n then
local u=u(i(e("*t")),i(e("!*t")));
local t=0;
if o~=""and o~="Z"then
local o,a,e=o:match("([+%-])(%d%d):?(%d*)");
if not o then return;end
if#e~=2 then e="0";end
a,e=l(a),l(e);
t=a*60*60+e*60;
if o=="-"then t=-t;end
end
a=(a+u)-t;
return i({year=n,month=r,day=s,hour=h,min=d,sec=a,isdst=false});
end
end
end
return _M;
end)
package.preload['util.sasl.scram']=(function(...)
local i,c=require"mime".b64,require"mime".unb64;
local a=require"crypto";
local t=require"bit";
local p=tonumber;
local o,e=string.char,string.byte;
local n=string.gsub;
local s=t.bxor;
local function m(t,a)
return(n(t,"()(.)",function(i,t)
return o(s(e(t),e(a,i)))
end));
end
local function w(e)
return a.digest("sha1",e,true);
end
local t=a.hmac.digest;
local function e(e,a)
return t("sha1",a,e,true);
end
local function y(o,t,i)
local t=e(o,t.."\0\0\0\1");
local a=t;
for i=2,i do
t=e(o,t);
a=m(a,t);
end
return a;
end
local function f(e)
return e;
end
local function t(e)
return(n(e,"[,=]",{[","]="=2C",["="]="=3D"}));
end
local function n(o,d)
local t="n="..t(o.username);
local n=i(a.rand.bytes(15));
local r="r="..n;
local h=t..","..r;
local s="";
local t=o.conn:ssl()and"y"or"n";
if d=="SCRAM-SHA-1-PLUS"then
s=o.conn:socket():getfinished();
t="p=tls-unique";
end
local d=t..",,";
local t=d..h;
local t,u=coroutine.yield(t);
if t~="challenge"then return false end
local a,t,l=u:match("(r=[^,]+),s=([^,]*),i=(%d+)");
local l=p(l);
t=c(t);
if not a or not t or not l then
return false,"Could not parse server_first_message";
elseif a:find(n,3,true)~=3 then
return false,"nonce sent by server does not match our nonce";
elseif a==r then
return false,"server did not append s-nonce to nonce";
end
local n=d..s;
local n="c="..i(n);
local n=n..","..a;
local o=y(f(o.password),t,l);
local t=e(o,"Client Key");
local s=w(t);
local a=h..","..u..","..n;
local s=e(s,a);
local t=m(t,s);
local o=e(o,"Server Key");
local e=e(o,a);
local t="p="..i(t);
local t=n..","..t;
local t,a=coroutine.yield(t);
if t~="success"then return false,"success-expected"end
local t=a:match("v=([^,]+)");
if c(t)~=e then
return false,"server signature did not match";
end
return true;
end
return function(e,t)
if e.username and(e.password or(e.client_key or e.server_key))then
if t=="SCRAM-SHA-1"then
return n,99;
elseif t=="SCRAM-SHA-1-PLUS"then
local e=e.conn:ssl()and e.conn:socket();
if e and e.getfinished then
return n,100;
end
end
end
end
end)
package.preload['util.sasl.plain']=(function(...)
return function(e,t)
if t=="PLAIN"and e.username and e.password then
return function(e)
return"success"==coroutine.yield("\0"..e.username.."\0"..e.password);
end,5;
end
end
end)
package.preload['util.sasl.anonymous']=(function(...)
return function(t,e)
if e=="ANONYMOUS"then
return function()
return coroutine.yield()=="success";
end,0;
end
end
end)
package.preload['verse.plugins.tls']=(function(...)
local a=require"verse";
local t="urn:ietf:params:xml:ns:xmpp-tls";
function a.plugins.tls(e)
local function i(o)
if e.authenticated then return;end
if o:get_child("starttls",t)and e.conn.starttls then
e:debug("Negotiating TLS...");
e:send(a.stanza("starttls",{xmlns=t}));
return true;
elseif not e.conn.starttls and not e.secure then
e:warn("SSL libary (LuaSec) not loaded, so TLS not available");
elseif not e.secure then
e:debug("Server doesn't offer TLS :(");
end
end
local function o(t)
if t.name=="proceed"then
e:debug("Server says proceed, handshake starting...");
e.conn:starttls({mode="client",protocol="sslv23",options="no_sslv2"},true);
end
end
local function a(t)
if t=="ssl-handshake-complete"then
e.secure=true;
e:debug("Re-opening stream...");
e:reopen();
end
end
e:hook("stream-features",i,400);
e:hook("stream/"..t,o);
e:hook("status",a,400);
return true;
end
end)
package.preload['verse.plugins.sasl']=(function(...)
local n,h=require"mime".b64,require"mime".unb64;
local a="urn:ietf:params:xml:ns:xmpp-sasl";
function verse.plugins.sasl(e)
local function s(t)
if e.authenticated then return;end
e:debug("Authenticating with SASL...");
local t=t:get_child("mechanisms",a);
if not t then return end
local o={};
local i={};
for t in t:childtags("mechanism")do
t=t:get_text();
e:debug("Server offers %s",t);
if not o[t]then
local n=t:match("[^-]+");
local s,a=pcall(require,"util.sasl."..n:lower());
if s then
e:debug("Loaded SASL %s module",n);
o[t],i[t]=a(e,t);
elseif not tostring(a):match("not found")then
e:debug("Loading failed: %s",tostring(a));
end
end
end
local t={};
for e in pairs(o)do
table.insert(t,e);
end
if not t[1]then
e:event("authentication-failure",{condition="no-supported-sasl-mechanisms"});
e:close();
return;
end
table.sort(t,function(e,t)return i[e]>i[t];end);
local t,i=t[1];
e:debug("Selecting %s mechanism...",t);
e.sasl_mechanism=coroutine.wrap(o[t]);
i=e:sasl_mechanism(t);
local t=verse.stanza("auth",{xmlns=a,mechanism=t});
if i then
t:text(n(i));
end
e:send(t);
return true;
end
local function o(t)
if t.name=="failure"then
local a=t.tags[1];
local t=t:get_child_text("text");
e:event("authentication-failure",{condition=a.name,text=t});
e:close();
return false;
end
local t,o=e.sasl_mechanism(t.name,h(t:get_text()));
if not t then
e:event("authentication-failure",{condition=o});
e:close();
return false;
elseif t==true then
e:event("authentication-success");
e.authenticated=true
e:reopen();
else
e:send(verse.stanza("response",{xmlns=a}):text(n(t)));
end
return true;
end
e:hook("stream-features",s,300);
e:hook("stream/"..a,o);
return true;
end
end)
package.preload['verse.plugins.bind']=(function(...)
local t=require"verse";
local i=require"util.jid";
local a="urn:ietf:params:xml:ns:xmpp-bind";
function t.plugins.bind(e)
local function o(o)
if e.bound then return;end
e:debug("Binding resource...");
e:send_iq(t.iq({type="set"}):tag("bind",{xmlns=a}):tag("resource"):text(e.resource),
function(t)
if t.attr.type=="result"then
local t=t
:get_child("bind",a)
:get_child_text("jid");
e.username,e.host,e.resource=i.split(t);
e.jid,e.bound=t,true;
e:event("bind-success",{jid=t});
elseif t.attr.type=="error"then
local a=t:child_with_name("error");
local o,t,a=t:get_error();
e:event("bind-failure",{error=t,text=a,type=o});
end
end);
end
e:hook("stream-features",o,200);
return true;
end
end)
package.preload['verse.plugins.session']=(function(...)
local o=require"verse";
local t="urn:ietf:params:xml:ns:xmpp-session";
function o.plugins.session(e)
local function n(a)
local a=a:get_child("session",t);
if a and not a:get_child("optional")then
local function i(a)
e:debug("Establishing Session...");
e:send_iq(o.iq({type="set"}):tag("session",{xmlns=t}),
function(t)
if t.attr.type=="result"then
e:event("session-success");
elseif t.attr.type=="error"then
local a=t:child_with_name("error");
local o,t,a=t:get_error();
e:event("session-failure",{error=t,text=a,type=o});
end
end);
return true;
end
e:hook("bind-success",i);
end
end
e:hook("stream-features",n);
return true;
end
end)
package.preload['verse.plugins.legacy']=(function(...)
local i=require"verse";
local n=require"util.uuid".generate;
local o="jabber:iq:auth";
function i.plugins.legacy(e)
function handle_auth_form(t)
local a=t:get_child("query",o);
if t.attr.type~="result"or not a then
local a,o,t=t:get_error();
e:debug("warn","%s %s: %s",a,o,t);
end
local t={
username=e.username;
password=e.password;
resource=e.resource or n();
digest=false,sequence=false,token=false;
};
local o=i.iq({to=e.host,type="set"})
:tag("query",{xmlns=o});
if#a>0 then
for a in a:childtags()do
local a=a.name;
local i=t[a];
if i then
o:tag(a):text(t[a]):up();
elseif i==nil then
local t="feature-not-implemented";
e:event("authentication-failure",{condition=t});
return false;
end
end
else
for t,e in pairs(t)do
if e then
o:tag(t):text(e):up();
end
end
end
e:send_iq(o,function(a)
if a.attr.type=="result"then
e.resource=t.resource;
e.jid=t.username.."@"..e.host.."/"..t.resource;
e:event("authentication-success");
e:event("bind-success",e.jid);
else
local a,t,a=a:get_error();
e:event("authentication-failure",{condition=t});
end
end);
end
function handle_opened(t)
if not t.version then
e:send_iq(i.iq({type="get"})
:tag("query",{xmlns="jabber:iq:auth"})
:tag("username"):text(e.username),
handle_auth_form);
end
end
e:hook("opened",handle_opened);
end
end)
package.preload['verse.plugins.compression']=(function(...)
local a=require"verse";
local o=require"zlib";
local e="http://jabber.org/features/compress"
local t="http://jabber.org/protocol/compress"
local e="http://etherx.jabber.org/streams";
local i=9;
local function s(e)
local i,o=pcall(o.deflate,i);
if i==false then
local t=a.stanza("failure",{xmlns=t}):tag("setup-failed");
e:send(t);
e:error("Failed to create zlib.deflate filter: %s",tostring(o));
return
end
return o
end
local function h(e)
local i,o=pcall(o.inflate);
if i==false then
local t=a.stanza("failure",{xmlns=t}):tag("setup-failed");
e:send(t);
e:error("Failed to create zlib.inflate filter: %s",tostring(o));
return
end
return o
end
local function r(e,i)
function e:send(o)
local i,o,n=pcall(i,tostring(o),'sync');
if i==false then
e:close({
condition="undefined-condition";
text=o;
extra=a.stanza("failure",{xmlns=t}):tag("processing-failed");
});
e:warn("Compressed send failed: %s",tostring(o));
return;
end
e.conn:write(o);
end;
end
local function d(e,o)
local n=e.data
e.data=function(s,i)
e:debug("Decompressing data...");
local i,o,h=pcall(o,i);
if i==false then
e:close({
condition="undefined-condition";
text=o;
extra=a.stanza("failure",{xmlns=t}):tag("processing-failed");
});
stream:warn("%s",tostring(o));
return;
end
return n(s,o);
end;
end
function a.plugins.compression(e)
local function n(o)
if not e.compressed then
local o=o:child_with_name("compression");
if o then
for o in o:children()do
local o=o[1]
if o=="zlib"then
e:send(a.stanza("compress",{xmlns=t}):tag("method"):text("zlib"))
e:debug("Enabled compression using zlib.")
return true;
end
end
session:debug("Remote server supports no compression algorithm we support.")
end
end
end
local function i(o)
if o.name=="compressed"then
e:debug("Activating compression...")
local a=s(e);
if not a then return end
local t=h(e);
if not t then return end
r(e,a);
d(e,t);
e.compressed=true;
e:reopen();
elseif o.name=="failure"then
e:warn("Failed to establish compression");
end
end
e:hook("stream-features",n,250);
e:hook("stream/"..t,i);
end
end)
package.preload['verse.plugins.smacks']=(function(...)
local i=require"verse";
local h=socket.gettime;
local n="urn:xmpp:sm:2";
function i.plugins.smacks(e)
local t={};
local a=0;
local r=h();
local o;
local s=0;
local function d(t)
if t.attr.xmlns=="jabber:client"or not t.attr.xmlns then
s=s+1;
e:debug("Increasing handled stanzas to %d for %s",s,t:top_tag());
end
end
function outgoing_stanza(a)
if a.name and not a.attr.xmlns then
t[#t+1]=tostring(a);
r=h();
if not o then
o=true;
e:debug("Waiting to send ack request...");
i.add_task(1,function()
if#t==0 then
o=false;
return;
end
local a=h()-r;
if a<1 and#t<10 then
return 1-a;
end
e:debug("Time up, sending <r>...");
o=false;
e:send(i.stanza("r",{xmlns=n}));
end);
end
end
end
local function h()
e:debug("smacks: connection lost");
e.stream_management_supported=nil;
if e.resumption_token then
e:debug("smacks: have resumption token, reconnecting in 1s...");
e.authenticated=nil;
i.add_task(1,function()
e:connect(e.connect_host or e.host,e.connect_port or 5222);
end);
return true;
end
end
local function r()
e.resumption_token=nil;
e:unhook("disconnected",h);
end
local function l(o)
if o.name=="r"then
e:debug("Ack requested... acking %d handled stanzas",s);
e:send(i.stanza("a",{xmlns=n,h=tostring(s)}));
elseif o.name=="a"then
local o=tonumber(o.attr.h);
if o>a then
local i=#t;
for a=a+1,o do
table.remove(t,1);
end
e:debug("Received ack: New ack: "..o.." Last ack: "..a.." Unacked stanzas now: "..#t.." (was "..i..")");
a=o;
else
e:warn("Received bad ack for "..o.." when last ack was "..a);
end
elseif o.name=="enabled"then
if o.attr.id then
e.resumption_token=o.attr.id;
e:hook("closed",r,100);
e:hook("disconnected",h,100);
end
elseif o.name=="resumed"then
local o=tonumber(o.attr.h);
if o>a then
local i=#t;
for a=a+1,o do
table.remove(t,1);
end
e:debug("Received ack: New ack: "..o.." Last ack: "..a.." Unacked stanzas now: "..#t.." (was "..i..")");
a=o;
end
for a=1,#t do
e:send(t[a]);
end
t={};
e:debug("Resumed successfully");
e:event("resumed");
else
e:warn("Don't know how to handle "..n.."/"..o.name);
end
end
local function a()
if not e.smacks then
e:debug("smacks: sending enable");
e:send(i.stanza("enable",{xmlns=n,resume="true"}));
e.smacks=true;
e:hook("stanza",d);
e:hook("outgoing",outgoing_stanza);
end
end
local function t(t)
if t:get_child("sm",n)then
e.stream_management_supported=true;
if e.smacks and e.bound then
e:debug("Resuming stream with %d handled stanzas",s);
e:send(i.stanza("resume",{xmlns=n,
h=s,previd=e.resumption_token}));
return true;
else
e:hook("bind-success",a,1);
end
end
end
e:hook("stream-features",t,250);
e:hook("stream/"..n,l);
end
end)
package.preload['verse.plugins.keepalive']=(function(...)
local t=require"verse";
function t.plugins.keepalive(e)
e.keepalive_timeout=e.keepalive_timeout or 300;
t.add_task(e.keepalive_timeout,function()
e.conn:write(" ");
return e.keepalive_timeout;
end);
end
end)
package.preload['verse.plugins.disco']=(function(...)
local a=require"verse";
local h=require("mime").b64;
local n=require("util.sha1").sha1;
local s="http://jabber.org/protocol/caps";
local e="http://jabber.org/protocol/disco";
local o=e.."#info";
local i=e.."#items";
function a.plugins.disco(e)
e:add_plugin("presence");
local t={
__index=function(a,e)
local t={identities={},features={}};
if e=="identities"or e=="features"then
return a[false][e]
end
a[e]=t;
return t;
end,
};
local r={
__index=function(t,a)
local e={};
t[a]=e;
return e;
end,
};
e.disco={
cache={},
info=setmetatable({
[false]={
identities={
{category='client',type='pc',name='Verse'},
},
features={
[s]=true,
[o]=true,
[i]=true,
},
},
},t);
items=setmetatable({[false]={}},r);
};
e.caps={}
e.caps.node='http://code.matthewwild.co.uk/verse/'
local function d(t,e)
if t.category<e.category then
return true;
elseif e.category<t.category then
return false;
end
if t.type<e.type then
return true;
elseif e.type<t.type then
return false;
end
if(not t['xml:lang']and e['xml:lang'])or
(e['xml:lang']and t['xml:lang']<e['xml:lang'])then
return true
end
return false
end
local function l(e,t)
return e.var<t.var
end
local function r(a)
local o=e.disco.info[a or false].identities;
table.sort(o,d)
local t={};
for e in pairs(e.disco.info[a or false].features)do
t[#t+1]={var=e};
end
table.sort(t,l)
local e={};
for a,t in pairs(o)do
e[#e+1]=table.concat({
t.category,t.type or'',
t['xml:lang']or'',t.name or''
},'/');
end
for a,t in pairs(t)do
e[#e+1]=t.var
end
e[#e+1]='';
e=table.concat(e,'<');
return(h(n(e)))
end
setmetatable(e.caps,{
__call=function(...)
local t=r()
e.caps.hash=t;
return a.stanza('c',{
xmlns=s,
hash='sha-1',
node=e.caps.node,
ver=t
})
end
})
function e:set_identity(t,a)
self.disco.info[a or false].identities={t};
e:resend_presence();
end
function e:add_identity(a,t)
local t=self.disco.info[t or false].identities;
t[#t+1]=a;
e:resend_presence();
end
function e:add_disco_feature(t,a)
local t=t.var or t;
self.disco.info[a or false].features[t]=true;
e:resend_presence();
end
function e:remove_disco_feature(t,a)
local t=t.var or t;
self.disco.info[a or false].features[t]=nil;
e:resend_presence();
end
function e:add_disco_item(t,e)
local e=self.disco.items[e or false];
e[#e+1]=t;
end
function e:remove_disco_item(a,e)
local e=self.disco.items[e or false];
for t=#e,1,-1 do
if e[t]==a then
table.remove(e,t);
end
end
end
function e:jid_has_identity(e,t,a)
local o=self.disco.cache[e];
if not o then
return nil,"no-cache";
end
local e=self.disco.cache[e].identities;
if a then
return e[t.."/"..a]or false;
end
for e in pairs(e)do
if e:match("^(.*)/")==t then
return true;
end
end
end
function e:jid_supports(e,t)
local e=self.disco.cache[e];
if not e or not e.features then
return nil,"no-cache";
end
return e.features[t]or false;
end
function e:get_local_services(a,o)
local e=self.disco.cache[self.host];
if not(e)or not(e.items)then
return nil,"no-cache";
end
local t={};
for i,e in ipairs(e.items)do
if self:jid_has_identity(e.jid,a,o)then
table.insert(t,e.jid);
end
end
return t;
end
function e:disco_local_services(a)
self:disco_items(self.host,nil,function(t)
if not t then
return a({});
end
local e=0;
local function o()
e=e-1;
if e==0 then
return a(t);
end
end
for a,t in ipairs(t)do
if t.jid then
e=e+1;
self:disco_info(t.jid,nil,o);
end
end
if e==0 then
return a(t);
end
end);
end
function e:disco_info(e,t,s)
local a=a.iq({to=e,type="get"})
:tag("query",{xmlns=o,node=t});
self:send_iq(a,function(n)
if n.attr.type=="error"then
return s(nil,n:get_error());
end
local i,a={},{};
for e in n:get_child("query",o):childtags()do
if e.name=="identity"then
i[e.attr.category.."/"..e.attr.type]=e.attr.name or true;
elseif e.name=="feature"then
a[e.attr.var]=true;
end
end
if not self.disco.cache[e]then
self.disco.cache[e]={nodes={}};
end
if t then
if not self.disco.cache[e].nodes[t]then
self.disco.cache[e].nodes[t]={nodes={}};
end
self.disco.cache[e].nodes[t].identities=i;
self.disco.cache[e].nodes[t].features=a;
else
self.disco.cache[e].identities=i;
self.disco.cache[e].features=a;
end
return s(self.disco.cache[e]);
end);
end
function e:disco_items(t,o,n)
local a=a.iq({to=t,type="get"})
:tag("query",{xmlns=i,node=o});
self:send_iq(a,function(a)
if a.attr.type=="error"then
return n(nil,a:get_error());
end
local e={};
for t in a:get_child("query",i):childtags()do
if t.name=="item"then
table.insert(e,{
name=t.attr.name;
jid=t.attr.jid;
node=t.attr.node;
});
end
end
if not self.disco.cache[t]then
self.disco.cache[t]={nodes={}};
end
if o then
if not self.disco.cache[t].nodes[o]then
self.disco.cache[t].nodes[o]={nodes={}};
end
self.disco.cache[t].nodes[o].items=e;
else
self.disco.cache[t].items=e;
end
return n(e);
end);
end
e:hook("iq/"..o,function(i)
local t=i.tags[1];
if i.attr.type=='get'and t.name=="query"then
local t=t.attr.node;
local n=e.disco.info[t or false];
if t and t==e.caps.node.."#"..e.caps.hash then
n=e.disco.info[false];
end
local n,s=n.identities,n.features
local t=a.reply(i):tag("query",{
xmlns=o,
node=t,
});
for a,e in pairs(n)do
t:tag('identity',e):up()
end
for a in pairs(s)do
t:tag('feature',{var=a}):up()
end
e:send(t);
return true
end
end);
e:hook("iq/"..i,function(t)
local o=t.tags[1];
if t.attr.type=='get'and o.name=="query"then
local n=e.disco.items[o.attr.node or false];
local t=a.reply(t):tag('query',{
xmlns=i,
node=o.attr.node
})
for a=1,#n do
t:tag('item',n[a]):up()
end
e:send(t);
return true
end
end);
local t;
e:hook("ready",function()
if t then return;end
t=true;
e:disco_local_services(function(t)
for t,a in ipairs(t)do
local t=e.disco.cache[a.jid];
if t then
for t in pairs(t.identities)do
local t,o=t:match("^(.*)/(.*)$");
e:event("disco/service-discovered/"..t,{
type=o,jid=a.jid;
});
end
end
end
e:event("ready");
end);
return true;
end,50);
e:hook("presence-out",function(t)
if not t:get_child("c",s)then
t:reset():add_child(e:caps()):reset();
end
end,10);
end
end)
package.preload['verse.plugins.version']=(function(...)
local o=require"verse";
local a="jabber:iq:version";
local function i(t,e)
t.name=e.name;
t.version=e.version;
t.platform=e.platform;
end
function o.plugins.version(e)
e.version={set=i};
e:hook("iq/"..a,function(t)
if t.attr.type~="get"then return;end
local t=o.reply(t)
:tag("query",{xmlns=a});
if e.version.name then
t:tag("name"):text(tostring(e.version.name)):up();
end
if e.version.version then
t:tag("version"):text(tostring(e.version.version)):up()
end
if e.version.platform then
t:tag("os"):text(e.version.platform);
end
e:send(t);
return true;
end);
function e:query_version(i,t)
t=t or function(t)return e:event("version/response",t);end
e:send_iq(o.iq({type="get",to=i})
:tag("query",{xmlns=a}),
function(o)
if o.attr.type=="result"then
local e=o:get_child("query",a);
local o=e and e:get_child_text("name");
local a=e and e:get_child_text("version");
local e=e and e:get_child_text("os");
t({
name=o;
version=a;
platform=e;
});
else
local a,o,e=o:get_error();
t({
error=true;
condition=o;
text=e;
type=a;
});
end
end);
end
return true;
end
end)
package.preload['verse.plugins.ping']=(function(...)
local a=require"verse";
local i="urn:xmpp:ping";
function a.plugins.ping(e)
function e:ping(t,o)
local n=socket.gettime();
e:send_iq(a.iq{to=t,type="get"}:tag("ping",{xmlns=i}),
function(e)
if e.attr.type=="error"then
local i,e,a=e:get_error();
if e~="service-unavailable"and e~="feature-not-implemented"then
o(nil,t,{type=i,condition=e,text=a});
return;
end
end
o(socket.gettime()-n,t);
end);
end
e:hook("iq/"..i,function(t)
return e:send(a.reply(t));
end);
return true;
end
end)
package.preload['verse.plugins.uptime']=(function(...)
local o=require"verse";
local t="jabber:iq:last";
local function a(e,t)
e.starttime=t.starttime;
end
function o.plugins.uptime(e)
e.uptime={set=a};
e:hook("iq/"..t,function(a)
if a.attr.type~="get"then return;end
local t=o.reply(a)
:tag("query",{seconds=tostring(os.difftime(os.time(),e.uptime.starttime)),xmlns=t});
e:send(t);
return true;
end);
function e:query_uptime(i,a)
a=a or function(t)return e:event("uptime/response",t);end
e:send_iq(o.iq({type="get",to=i})
:tag("query",{xmlns=t}),
function(e)
local t=e:get_child("query",t);
if e.attr.type=="result"then
local e=tonumber(t.attr.seconds);
a({
seconds=e or nil;
});
else
local o,t,e=e:get_error();
a({
error=true;
condition=t;
text=e;
type=o;
});
end
end);
end
return true;
end
end)
package.preload['verse.plugins.blocking']=(function(...)
local a=require"verse";
local o="urn:xmpp:blocking";
function a.plugins.blocking(e)
e.blocking={};
function e.blocking:block_jid(i,t)
e:send_iq(a.iq{type="set"}
:tag("block",{xmlns=o})
:tag("item",{jid=i})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:unblock_jid(i,t)
e:send_iq(a.iq{type="set"}
:tag("unblock",{xmlns=o})
:tag("item",{jid=i})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:unblock_all_jids(t)
e:send_iq(a.iq{type="set"}
:tag("unblock",{xmlns=o})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:get_blocked_jids(t)
e:send_iq(a.iq{type="get"}
:tag("blocklist",{xmlns=o})
,function(e)
local a=e:get_child("blocklist",o);
if not a then return t and t(false);end
local e={};
for t in a:childtags()do
e[#e+1]=t.attr.jid;
end
return t and t(e);
end
,function(e)return t and t(false);end
);
end
end
end)
package.preload['verse.plugins.jingle']=(function(...)
local a=require"verse";
local e=require"util.sha1".sha1;
local e=require"util.timer";
local n=require"util.uuid".generate;
local i="urn:xmpp:jingle:1";
local h="urn:xmpp:jingle:errors:1";
local t={};
t.__index=t;
local e={};
local e={};
function a.plugins.jingle(e)
e:hook("ready",function()
e:add_disco_feature(i);
end,10);
function e:jingle(o)
return a.eventable(setmetatable(base or{
role="initiator";
peer=o;
sid=n();
stream=e;
},t));
end
function e:register_jingle_transport(e)
end
function e:register_jingle_content_type(e)
end
local function u(n)
local d=n:get_child("jingle",i);
local o=d.attr.sid;
local s=d.attr.action;
local o=e:event("jingle/"..o,n);
if o==true then
e:send(a.reply(n));
return true;
end
if s~="session-initiate"then
local t=a.error_reply(n,"cancel","item-not-found")
:tag("unknown-session",{xmlns=h}):up();
e:send(t);
return;
end
local l=d.attr.sid;
local o=a.eventable{
role="receiver";
peer=n.attr.from;
sid=l;
stream=e;
};
setmetatable(o,t);
local r;
local s,h;
for t in d:childtags()do
if t.name=="content"and t.attr.xmlns==i then
local a=t:child_with_name("description");
local i=a.attr.xmlns;
if i then
local e=e:event("jingle/content/"..i,o,a);
if e then
s=e;
end
end
local a=t:child_with_name("transport");
local i=a.attr.xmlns;
h=e:event("jingle/transport/"..i,o,a);
if s and h then
r=t;
break;
end
end
end
if not s then
e:send(a.error_reply(n,"cancel","feature-not-implemented","The specified content is not supported"));
return true;
end
if not h then
e:send(a.error_reply(n,"cancel","feature-not-implemented","The specified transport is not supported"));
return true;
end
e:send(a.reply(n));
o.content_tag=r;
o.creator,o.name=r.attr.creator,r.attr.name;
o.content,o.transport=s,h;
function o:decline()
end
e:hook("jingle/"..l,function(e)
if e.attr.from~=o.peer then
return false;
end
local e=e:get_child("jingle",i);
return o:handle_command(e);
end);
e:event("jingle",o);
return true;
end
function t:handle_command(a)
local t=a.attr.action;
e:debug("Handling Jingle command: %s",t);
if t=="session-terminate"then
self:destroy();
elseif t=="session-accept"then
self:handle_accepted(a);
elseif t=="transport-info"then
e:debug("Handling transport-info");
self.transport:info_received(a);
elseif t=="transport-replace"then
e:error("Peer wanted to swap transport, not implemented");
else
e:warn("Unhandled Jingle command: %s",t);
return nil;
end
return true;
end
function t:send_command(e,o,t)
local e=a.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=i,
sid=self.sid,
action=e,
initiator=self.role=="initiator"and self.stream.jid or nil,
responder=self.role=="responder"and self.jid or nil,
}):add_child(o);
if not t then
self.stream:send(e);
else
self.stream:send_iq(e,t);
end
end
function t:accept(t)
local a=a.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=i,
sid=self.sid,
action="session-accept",
responder=e.jid,
})
:tag("content",{creator=self.creator,name=self.name});
local o=self.content:generate_accept(self.content_tag:child_with_name("description"),t);
a:add_child(o);
local t=self.transport:generate_accept(self.content_tag:child_with_name("transport"),t);
a:add_child(t);
local t=self;
e:send_iq(a,function(a)
if a.attr.type=="error"then
local a,t,a=a:get_error();
e:error("session-accept rejected: %s",t);
return false;
end
t.transport:connect(function(a)
e:warn("CONNECTED (receiver)!!!");
t.state="active";
t:event("connected",a);
end);
end);
end
e:hook("iq/"..i,u);
return true;
end
function t:offer(t,o)
local e=a.iq({to=self.peer,type="set"})
:tag("jingle",{xmlns=i,action="session-initiate",
initiator=self.stream.jid,sid=self.sid});
e:tag("content",{creator=self.role,name=t});
local t=self.stream:event("jingle/describe/"..t,o);
if not t then
return false,"Unknown content type";
end
e:add_child(t);
local t=self.stream:event("jingle/transport/".."urn:xmpp:jingle:transports:s5b:1",self);
self.transport=t;
e:add_child(t:generate_initiate());
self.stream:debug("Hooking %s","jingle/"..self.sid);
self.stream:hook("jingle/"..self.sid,function(e)
if e.attr.from~=self.peer then
return false;
end
local e=e:get_child("jingle",i);
return self:handle_command(e)
end);
self.stream:send_iq(e,function(e)
if e.attr.type=="error"then
self.state="terminated";
local a,t,e=e:get_error();
return self:event("error",{type=a,condition=t,text=e});
end
end);
self.state="pending";
end
function t:terminate(e)
local e=a.stanza("reason"):tag(e or"success");
self:send_command("session-terminate",e,function(e)
self.state="terminated";
self.transport:disconnect();
self:destroy();
end);
end
function t:destroy()
self:event("terminated");
self.stream:unhook("jingle/"..self.sid,self.handle_command);
end
function t:handle_accepted(e)
local e=e:child_with_name("transport");
self.transport:handle_accepted(e);
self.transport:connect(function(e)
self.stream:debug("CONNECTED (initiator)!")
self.state="active";
self:event("connected",e);
end);
end
function t:set_source(a,o)
local function t()
local e,i=a();
if e and e~=""then
self.transport.conn:send(e);
elseif e==""then
return t();
elseif e==nil then
if o then
self:terminate();
end
self.transport.conn:unhook("drained",t);
a=nil;
end
end
self.transport.conn:hook("drained",t);
t();
end
function t:set_sink(t)
self.transport.conn:hook("incoming-raw",t);
self.transport.conn:hook("disconnected",function(e)
self.stream:debug("Closing sink...");
local e=e.reason;
if e=="closed"then e=nil;end
t(nil,e);
end);
end
end)
package.preload['verse.plugins.jingle_ft']=(function(...)
local s=require"verse";
local n=require"ltn12";
local h=package.config:sub(1,1);
local a="urn:xmpp:jingle:apps:file-transfer:1";
local o="http://jabber.org/protocol/si/profile/file-transfer";
function s.plugins.jingle_ft(t)
t:hook("ready",function()
t:add_disco_feature(a);
end,10);
local i={type="file"};
function i:generate_accept(t,e)
if e and e.save_file then
self.jingle:hook("connected",function()
local e=n.sink.file(io.open(e.save_file,"w+"));
self.jingle:set_sink(e);
end);
end
return t;
end
local i={__index=i};
t:hook("jingle/content/"..a,function(t,e)
local e=e:get_child("offer"):get_child("file",o);
local e={
name=e.attr.name;
size=tonumber(e.attr.size);
};
return setmetatable({jingle=t,file=e},i);
end);
t:hook("jingle/describe/file",function(e)
local t;
if e.timestamp then
t=os.date("!%Y-%m-%dT%H:%M:%SZ",e.timestamp);
end
return s.stanza("description",{xmlns=a})
:tag("offer")
:tag("file",{xmlns=o,
name=e.filename,
size=e.size,
date=t,
hash=e.hash,
})
:tag("desc"):text(e.description or"");
end);
function t:send_file(a,t)
local e,o=io.open(t);
if not e then return e,o;end
local i=e:seek("end",0);
e:seek("set",0);
local o=n.source.file(e);
local e=self:jingle(a);
e:offer("file",{
filename=t:match("[^"..h.."]+$");
size=i;
});
e:hook("connected",function()
e:set_source(o,true);
end);
return e;
end
end
end)
package.preload['verse.plugins.jingle_s5b']=(function(...)
local a=require"verse";
local o="urn:xmpp:jingle:transports:s5b:1";
local r="http://jabber.org/protocol/bytestreams";
local s=require"util.sha1".sha1;
local d=require"util.uuid".generate;
local function n(e,t)
local function o()
e:unhook("connected",o);
return true;
end
local function a(t)
e:unhook("incoming-raw",a);
if t:sub(1,2)~="\005\000"then
return e:event("error","connection-failure");
end
e:event("connected");
return true;
end
local function i(o)
e:unhook("incoming-raw",i);
if o~="\005\000"then
local t="version-mismatch";
if o:sub(1,1)=="\005"then
t="authentication-failure";
end
return e:event("error",t);
end
e:send(string.char(5,1,0,3,#t)..t.."\0\0");
e:hook("incoming-raw",a,100);
return true;
end
e:hook("connected",o,200);
e:hook("incoming-raw",i,100);
e:send("\005\001\000");
end
local function h(o,e,i)
local e=a.new(nil,{
streamhosts=e,
current_host=0;
});
local function t(a)
if a then
return o(nil,a.reason);
end
if e.current_host<#e.streamhosts then
e.current_host=e.current_host+1;
e:debug("Attempting to connect to "..e.streamhosts[e.current_host].host..":"..e.streamhosts[e.current_host].port.."...");
local a,t=e:connect(
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port
);
if not a then
e:debug("Error connecting to proxy (%s:%s): %s",
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port,
t
);
else
e:debug("Connecting...");
end
n(e,i);
return true;
end
e:unhook("disconnected",t);
return o(nil);
end
e:hook("disconnected",t,100);
e:hook("connected",function()
e:unhook("disconnected",t);
o(e.streamhosts[e.current_host],e);
end,100);
t();
return e;
end
function a.plugins.jingle_s5b(e)
e:hook("ready",function()
e:add_disco_feature(o);
end,10);
local t={};
function t:generate_initiate()
self.s5b_sid=d();
local i=a.stanza("transport",{xmlns=o,
mode="tcp",sid=self.s5b_sid});
local t=0;
for a,o in pairs(e.proxy65.available_streamhosts)do
t=t+1;
i:tag("candidate",{jid=a,host=o.host,
port=o.port,cid=a,priority=t,type="proxy"}):up();
end
e:debug("Have %d proxies",t)
return i;
end
function t:generate_accept(e)
local t={};
self.s5b_peer_candidates=t;
self.s5b_mode=e.attr.mode or"tcp";
self.s5b_sid=e.attr.sid or self.jingle.sid;
for e in e:childtags()do
t[e.attr.cid]={
type=e.attr.type;
jid=e.attr.jid;
host=e.attr.host;
port=tonumber(e.attr.port)or 0;
priority=tonumber(e.attr.priority)or 0;
cid=e.attr.cid;
};
end
local e=a.stanza("transport",{xmlns=o});
return e;
end
function t:connect(i)
e:warn("Connecting!");
local t={};
for a,e in pairs(self.s5b_peer_candidates or{})do
t[#t+1]=e;
end
if#t>0 then
self.connecting_peer_candidates=true;
local function n(e,t)
self.jingle:send_command("transport-info",a.stanza("content",{creator=self.creator,name=self.name})
:tag("transport",{xmlns=o,sid=self.s5b_sid})
:tag("candidate-used",{cid=e.cid}));
self.onconnect_callback=i;
self.conn=t;
end
local e=s(self.s5b_sid..self.peer..e.jid,true);
h(n,t,e);
else
e:warn("Actually, I'm going to wait for my peer to tell me its streamhost...");
self.onconnect_callback=i;
end
end
function t:info_received(t)
e:warn("Info received");
local n=t:child_with_name("content");
local i=n:child_with_name("transport");
if i:get_child("candidate-used")and not self.connecting_peer_candidates then
local t=i:child_with_name("candidate-used");
if t then
local function d(i,e)
if self.jingle.role=="initiator"then
self.jingle.stream:send_iq(a.iq({to=i.jid,type="set"})
:tag("query",{xmlns=r,sid=self.s5b_sid})
:tag("activate"):text(self.jingle.peer),function(i)
if i.attr.type=="result"then
self.jingle:send_command("transport-info",a.stanza("content",n.attr)
:tag("transport",{xmlns=o,sid=self.s5b_sid})
:tag("activated",{cid=t.attr.cid}));
self.conn=e;
self.onconnect_callback(e);
else
self.jingle.stream:error("Failed to activate bytestream");
end
end);
end
end
self.jingle.stream:debug("CID: %s",self.jingle.stream.proxy65.available_streamhosts[t.attr.cid]);
local t={
self.jingle.stream.proxy65.available_streamhosts[t.attr.cid];
};
local e=s(self.s5b_sid..e.jid..self.peer,true);
h(d,t,e);
end
elseif i:get_child("activated")then
self.onconnect_callback(self.conn);
end
end
function t:disconnect()
if self.conn then
self.conn:close();
end
end
function t:handle_accepted(e)
end
local t={__index=t};
e:hook("jingle/transport/"..o,function(e)
return setmetatable({
role=e.role,
peer=e.peer,
stream=e.stream,
jingle=e,
},t);
end);
end
end)
package.preload['verse.plugins.proxy65']=(function(...)
local e=require"util.events";
local r=require"util.uuid";
local h=require"util.sha1";
local i={};
i.__index=i;
local o="http://jabber.org/protocol/bytestreams";
local n;
function verse.plugins.proxy65(t)
t.proxy65=setmetatable({stream=t},i);
t.proxy65.available_streamhosts={};
local e=0;
t:hook("disco/service-discovered/proxy",function(a)
if a.type=="bytestreams"then
e=e+1;
t:send_iq(verse.iq({to=a.jid,type="get"})
:tag("query",{xmlns=o}),function(a)
e=e-1;
if a.attr.type=="result"then
local e=a:get_child("query",o)
:get_child("streamhost").attr;
t.proxy65.available_streamhosts[e.jid]={
jid=e.jid;
host=e.host;
port=tonumber(e.port);
};
end
if e==0 then
t:event("proxy65/discovered-proxies",t.proxy65.available_streamhosts);
end
end);
end
end);
t:hook("iq/"..o,function(a)
local e=verse.new(nil,{
initiator_jid=a.attr.from,
streamhosts={},
current_host=0;
});
for t in a.tags[1]:childtags()do
if t.name=="streamhost"then
table.insert(e.streamhosts,t.attr);
end
end
local function o()
if e.current_host<#e.streamhosts then
e.current_host=e.current_host+1;
e:connect(
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port
);
n(t,e,a.tags[1].attr.sid,a.attr.from,t.jid);
return true;
end
e:unhook("disconnected",o);
t:send(verse.error_reply(a,"cancel","item-not-found"));
end
function e:accept()
e:hook("disconnected",o,100);
e:hook("connected",function()
e:unhook("disconnected",o);
local e=verse.reply(a)
:tag("query",a.tags[1].attr)
:tag("streamhost-used",{jid=e.streamhosts[e.current_host].jid});
t:send(e);
end,100);
o();
end
function e:refuse()
end
t:event("proxy65/request",e);
end);
end
function i:new(t,s)
local e=verse.new(nil,{
target_jid=t;
bytestream_sid=r.generate();
});
local a=verse.iq{type="set",to=t}
:tag("query",{xmlns=o,mode="tcp",sid=e.bytestream_sid});
for t,e in ipairs(s or self.proxies)do
a:tag("streamhost",e):up();
end
self.stream:send_iq(a,function(a)
if a.attr.type=="error"then
local t,a,o=a:get_error();
e:event("connection-failed",{conn=e,type=t,condition=a,text=o});
else
local a=a.tags[1]:get_child("streamhost-used");
if not a then
end
e.streamhost_jid=a.attr.jid;
local a,i;
for o,t in ipairs(s or self.proxies)do
if t.jid==e.streamhost_jid then
a,i=t.host,t.port;
break;
end
end
if not(a and i)then
end
e:connect(a,i);
local function a()
e:unhook("connected",a);
local t=verse.iq{to=e.streamhost_jid,type="set"}
:tag("query",{xmlns=o,sid=e.bytestream_sid})
:tag("activate"):text(t);
self.stream:send_iq(t,function(t)
if t.attr.type=="result"then
e:event("connected",e);
else
end
end);
return true;
end
e:hook("connected",a,100);
n(self.stream,e,e.bytestream_sid,self.stream.jid,t);
end
end);
return e;
end
function n(i,e,o,a,t)
local a=h.sha1(o..a..t);
local function t()
e:unhook("connected",t);
return true;
end
local function n(t)
e:unhook("incoming-raw",n);
if t:sub(1,2)~="\005\000"then
return e:event("error","connection-failure");
end
e:event("connected");
return true;
end
local function o(i)
e:unhook("incoming-raw",o);
if i~="\005\000"then
local t="version-mismatch";
if i:sub(1,1)=="\005"then
t="authentication-failure";
end
return e:event("error",t);
end
e:send(string.char(5,1,0,3,#a)..a.."\0\0");
e:hook("incoming-raw",n,100);
return true;
end
e:hook("connected",t,200);
e:hook("incoming-raw",o,100);
e:send("\005\001\000");
end
end)
package.preload['verse.plugins.jingle_ibb']=(function(...)
local e=require"verse";
local i=require"util.encodings".base64;
local s=require"util.uuid".generate;
local n="urn:xmpp:jingle:transports:ibb:1";
local o="http://jabber.org/protocol/ibb";
assert(i.encode("This is a test.")=="VGhpcyBpcyBhIHRlc3Qu","Base64 encoding failed");
assert(i.decode("VGhpcyBpcyBhIHRlc3Qu")=="This is a test.","Base64 decoding failed");
local t=table.concat
local a={};
local t={__index=a};
local function h(a)
local t=setmetatable({stream=a},t)
t=e.eventable(t);
return t;
end
function a:initiate(e,a,t)
self.block=2048;
self.stanza=t or'iq';
self.peer=e;
self.sid=a or tostring(self):match("%x+$");
self.iseq=0;
self.oseq=0;
local e=function(e)
return self:feed(e)
end
self.feeder=e;
print("Hooking incomming IQs");
local a=self.stream;
a:hook("iq/"..o,e)
if t=="message"then
a:hook("message",e)
end
end
function a:open(t)
self.stream:send_iq(e.iq{to=self.peer,type="set"}
:tag("open",{
xmlns=o,
["block-size"]=self.block,
sid=self.sid,
stanza=self.stanza
})
,function(e)
if t then
if e.attr.type~="error"then
t(true)
else
t(false,e:get_error())
end
end
end);
end
function a:send(n)
local a=self.stanza;
local t;
if a=="iq"then
t=e.iq{type="set",to=self.peer}
elseif a=="message"then
t=e.message{to=self.peer}
end
local e=self.oseq;
self.oseq=e+1;
t:tag("data",{xmlns=o,sid=self.sid,seq=e})
:text(i.encode(n));
if a=="iq"then
self.stream:send_iq(t,function(e)
self:event(e.attr.type=="result"and"drained"or"error");
end)
else
stream:send(t)
self:event("drained");
end
end
function a:feed(t)
if t.attr.from~=self.peer then return end
local a=t[1];
if a.attr.sid~=self.sid then return end
local n;
if a.name=="open"then
self:event("connected");
self.stream:send(e.reply(t))
return true
elseif a.name=="data"then
local o=t:get_child_text("data",o);
local a=tonumber(a.attr.seq);
local n=self.iseq;
if o and a then
if a~=n then
self.stream:send(e.error_reply(t,"cancel","not-acceptable","Wrong sequence. Packet lost?"))
self:close();
self:event("error");
return true;
end
self.iseq=a+1;
local a=i.decode(o);
if self.stanza=="iq"then
self.stream:send(e.reply(t))
end
self:event("incoming-raw",a);
return true;
end
elseif a.name=="close"then
self.stream:send(e.reply(t))
self:close();
return true
end
end
function a:close()
self.stream:unhook("iq/"..o,self.feeder)
self:event("disconnected");
end
function e.plugins.jingle_ibb(a)
a:hook("ready",function()
a:add_disco_feature(n);
end,10);
local t={};
function t:_setup()
local e=h(self.stream);
e.sid=self.sid or e.sid;
e.stanza=self.stanza or e.stanza;
e.block=self.block or e.block;
e:initiate(self.peer,self.sid,self.stanza);
self.conn=e;
end
function t:generate_initiate()
print("ibb:generate_initiate() as "..self.role);
local t=s();
self.sid=t;
self.stanza='iq';
self.block=2048;
local e=e.stanza("transport",{xmlns=n,
sid=self.sid,stanza=self.stanza,["block-size"]=self.block});
return e;
end
function t:generate_accept(t)
print("ibb:generate_accept() as "..self.role);
local e=t.attr;
self.sid=e.sid or self.sid;
self.stanza=e.stanza or self.stanza;
self.block=e["block-size"]or self.block;
self:_setup();
return t;
end
function t:connect(t)
if not self.conn then
self:_setup();
end
local e=self.conn;
print("ibb:connect() as "..self.role);
if self.role=="initiator"then
e:open(function(a,...)
assert(a,table.concat({...},", "));
t(e);
end);
else
t(e);
end
end
function t:info_received(e)
print("ibb:info_received()");
end
function t:disconnect()
if self.conn then
self.conn:close()
end
end
function t:handle_accepted(e)end
local t={__index=t};
a:hook("jingle/transport/"..n,function(e)
return setmetatable({
role=e.role,
peer=e.peer,
stream=e.stream,
jingle=e,
},t);
end);
end
end)
package.preload['verse.plugins.pubsub']=(function(...)
local h=require"verse";
local e=require"util.jid".bare;
local s=table.insert;
local o="http://jabber.org/protocol/pubsub";
local n="http://jabber.org/protocol/pubsub#owner";
local a="http://jabber.org/protocol/pubsub#event";
local e="http://jabber.org/protocol/pubsub#errors";
local e={};
local i={__index=e};
function h.plugins.pubsub(e)
e.pubsub=setmetatable({stream=e},i);
e:hook("message",function(t)
local o=t.attr.from;
for t in t:childtags("event",a)do
local t=t:get_child("items");
if t then
local a=t.attr.node;
for t in t:childtags("item")do
e:event("pubsub/event",{
from=o;
node=a;
item=t;
});
end
end
end
end);
return true;
end
function e:create(t,e,a)
return self:service(t):node(e):create(nil,a);
end
function e:subscribe(e,t,a,o)
return self:service(e):node(t):subscribe(a,nil,o);
end
function e:publish(a,e,i,o,t)
return self:service(a):node(e):publish(i,nil,o,t);
end
local a={};
local t={__index=a};
function e:service(e)
return setmetatable({stream=self.stream,service=e},t)
end
local function t(r,e,s,a,i,n,t)
local e=h.iq{type=r or"get",to=e}
:tag("pubsub",{xmlns=s or o})
if a then e:tag(a,{node=i,jid=n});end
if t then e:tag("item",{id=t~=true and t or nil});end
return e;
end
function a:subscriptions(a)
self.stream:send_iq(t(nil,self.service,nil,"subscriptions")
,a and function(e)
if e.attr.type=="result"then
local e=e:get_child("pubsub",o);
local e=e and e:get_child("subscriptions");
local o={};
if e then
for e in e:childtags("subscription")do
local t=self:node(e.attr.node)
t.subscription=e;
t.subscribed_jid=e.attr.jid;
s(o,t);
end
end
a(o);
else
a(false,e:get_error());
end
end or nil);
end
function a:affiliations(a)
self.stream:send_iq(t(nil,self.service,nil,"affiliations")
,a and function(e)
if e.attr.type=="result"then
local e=e:get_child("pubsub",o);
local e=e and e:get_child("affiliations")or{};
local o={};
if e then
for t in e:childtags("affiliation")do
local e=self:node(t.attr.node)
e.affiliation=t;
s(o,e);
end
end
a(o);
else
a(false,e:get_error());
end
end or nil);
end
function a:nodes(a)
self.stream:disco_items(self.service,nil,function(e,...)
if e then
for t=1,#e do
e[t]=self:node(e[t].node);
end
end
a(e,...)
end);
end
local e={};
local o={__index=e};
function a:node(e)
return setmetatable({stream=self.stream,service=self.service,node=e},o)
end
function i:__call(t,e)
local t=self:service(t);
return e and t:node(e)or t;
end
function e:hook(a,o)
self._hooks=self._hooks or setmetatable({},{__mode='kv'});
local function t(e)
if(not e.service or e.from==self.service)and e.node==self.node then
return a(e)
end
end
self._hooks[a]=t;
self.stream:hook("pubsub/event",t,o);
return t;
end
function e:unhook(e)
if e then
local e=self._hooks[e];
self.stream:unhook("pubsub/event",e);
elseif self._hooks then
for e in pairs(self._hooks)do
self.stream:unhook("pubsub/event",e);
end
end
end
function e:create(a,e)
if a~=nil then
error("Not implemented yet.");
else
self.stream:send_iq(t("set",self.service,nil,"create",self.node),e);
end
end
function e:configure(e,a)
if e~=nil then
error("Not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,e==nil and"default"or"configure",self.node),a);
end
function e:publish(i,o,e,a)
if o~=nil then
error("Node configuration is not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,"publish",self.node,nil,i or true)
:add_child(e)
,a);
end
function e:subscribe(e,o,a)
e=e or self.stream.jid;
if o~=nil then
error("Subscription configuration is not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,"subscribe",self.node,e,id)
,a);
end
function e:subscription(e)
error("Not implemented yet.");
end
function e:affiliation(e)
error("Not implemented yet.");
end
function e:unsubscribe(e,a)
e=e or self.subscribed_jid or self.stream.jid;
self.stream:send_iq(t("set",self.service,nil,"unsubscribe",self.node,e)
,a);
end
function e:configure_subscription(e,e)
error("Not implemented yet.");
end
function e:items(a,e)
if a then
self.stream:send_iq(t("get",self.service,nil,"items",self.node)
,e);
else
self.stream:disco_items(self.service,self.node,e);
end
end
function e:item(e,a)
self.stream:send_iq(t("get",self.service,nil,"items",self.node,nil,e)
,a);
end
function e:retract(a,e)
self.stream:send_iq(t("set",self.service,nil,"retract",self.node,nil,a)
,e);
end
function e:purge(e,a)
assert(not e,"Not implemented yet.");
self.stream:send_iq(t("set",self.service,n,"purge",self.node)
,a);
end
function e:delete(e,a)
assert(not e,"Not implemented yet.");
self.stream:send_iq(t("set",self.service,n,"delete",self.node)
,a);
end
end)
package.preload['verse.plugins.pep']=(function(...)
local e=require"verse";
local t="http://jabber.org/protocol/pubsub";
local t=t.."#event";
function e.plugins.pep(e)
e:add_plugin("disco");
e:add_plugin("pubsub");
e.pep={};
e:hook("pubsub/event",function(t)
return e:event("pep/"..t.node,{from=t.from,item=t.item.tags[1]});
end);
function e:hook_pep(t,o,i)
local a=e.events._handlers["pep/"..t];
if not(a)or#a==0 then
e:add_disco_feature(t.."+notify");
end
e:hook("pep/"..t,o,i);
end
function e:unhook_pep(t,a)
e:unhook("pep/"..t,a);
local a=e.events._handlers["pep/"..t];
if not(a)or#a==0 then
e:remove_disco_feature(t.."+notify");
end
end
function e:publish_pep(t,a)
return e.pubsub:service(nil):node(a or t.attr.xmlns):publish(nil,nil,t)
end
end
end)
package.preload['verse.plugins.adhoc']=(function(...)
local o=require"verse";
local n=require"lib.adhoc";
local t="http://jabber.org/protocol/commands";
local h="jabber:x:data";
local a={};
a.__index=a;
local i={};
function o.plugins.adhoc(e)
e:add_plugin("disco");
e:add_disco_feature(t);
function e:query_commands(a,o)
e:disco_items(a,t,function(t)
e:debug("adhoc list returned")
local a={};
for o,t in ipairs(t)do
a[t.node]=t.name;
end
e:debug("adhoc calling callback")
return o(a);
end);
end
function e:execute_command(t,o,i)
local e=setmetatable({
stream=e,jid=t,
command=o,callback=i
},a);
return e:execute();
end
local function s(t,e)
if not(e)or e=="user"then return true;end
if type(e)=="function"then
return e(t);
end
end
function e:add_adhoc_command(o,a,s,h)
i[a]=n.new(o,a,s,h);
e:add_disco_item({jid=e.jid,node=a,name=o},t);
return i[a];
end
local function h(a)
local t=a.tags[1];
local t=t.attr.node;
local t=i[t];
if not t then return;end
if not s(a.attr.from,t.permission)then
e:send(o.error_reply(a,"auth","forbidden","You don't have permission to execute this command"):up()
:add_child(t:cmdtag("canceled")
:tag("note",{type="error"}):text("You don't have permission to execute this command")));
return true
end
return n.handle_cmd(t,{send=function(t)return e:send(t)end},a);
end
e:hook("iq/"..t,function(e)
local t=e.attr.type;
local a=e.tags[1].name;
if t=="set"and a=="command"then
return h(e);
end
end);
end
function a:_process_response(e)
if e.attr.type=="error"then
self.status="canceled";
self.callback(self,{});
return;
end
local e=e:get_child("command",t);
self.status=e.attr.status;
self.sessionid=e.attr.sessionid;
self.form=e:get_child("x",h);
self.note=e:get_child("note");
self.callback(self);
end
function a:execute()
local e=o.iq({to=self.jid,type="set"})
:tag("command",{xmlns=t,node=self.command});
self.stream:send_iq(e,function(e)
self:_process_response(e);
end);
end
function a:next(a)
local e=o.iq({to=self.jid,type="set"})
:tag("command",{
xmlns=t,
node=self.command,
sessionid=self.sessionid
});
if a then e:add_child(a);end
self.stream:send_iq(e,function(e)
self:_process_response(e);
end);
end
end)
package.preload['verse.plugins.presence']=(function(...)
local a=require"verse";
function a.plugins.presence(e)
e.last_presence=nil;
e:hook("presence-out",function(t)
if not t.attr.to then
e.last_presence=t;
end
end,1);
function e:resend_presence()
if last_presence then
e:send(last_presence);
end
end
function e:set_status(t)
local a=a.presence();
if type(t)=="table"then
if t.show then
a:tag("show"):text(t.show):up();
end
if t.prio then
a:tag("priority"):text(tostring(t.prio)):up();
end
if t.msg then
a:tag("status"):text(t.msg):up();
end
end
e:send(a);
end
end
end)
package.preload['verse.plugins.private']=(function(...)
local o=require"verse";
local a="jabber:iq:private";
function o.plugins.private(i)
function i:private_set(i,n,e,s)
local t=o.iq({type="set"})
:tag("query",{xmlns=a});
if e then
if e.name==i and e.attr and e.attr.xmlns==n then
t:add_child(e);
else
t:tag(i,{xmlns=n})
:add_child(e);
end
end
self:send_iq(t,s);
end
function i:private_get(e,t,i)
self:send_iq(o.iq({type="get"})
:tag("query",{xmlns=a})
:tag(e,{xmlns=t}),
function(o)
if o.attr.type=="result"then
local a=o:get_child("query",a);
local e=a:get_child(e,t);
i(e);
end
end);
end
end
end)
package.preload['verse.plugins.roster']=(function(...)
local o=require"verse";
local r=require"util.jid".bare;
local a="jabber:iq:roster";
local i="urn:xmpp:features:rosterver";
local n=table.insert;
function o.plugins.roster(t)
local s=false;
local e={
items={};
ver="";
};
t.roster=e;
t:hook("stream-features",function(e)
if e:get_child("ver",i)then
s=true;
end
end);
local function h(t)
local e=o.stanza("item",{xmlns=a});
for a,t in pairs(t)do
if a~="groups"then
e.attr[a]=t;
else
for a=1,#t do
e:tag("group"):text(t[a]):up();
end
end
end
return e;
end
local function d(e)
local t={};
local a={};
t.groups=a;
local o=e.attr.jid;
for e,a in pairs(e.attr)do
if e~="xmlns"then
t[e]=a
end
end
for e in e:childtags("group")do
n(a,e:get_text())
end
return t;
end
function e:load(t)
e.ver,e.items=t.ver,t.items;
end
function e:dump()
return{
ver=e.ver,
items=e.items,
};
end
function e:add_contact(s,i,n,e)
local i={jid=s,name=i,groups=n};
local a=o.iq({type="set"})
:tag("query",{xmlns=a})
:add_child(h(i));
t:send_iq(a,function(t)
if not e then return end
if t.attr.type=="result"then
e(true);
else
local t,a,o=t:get_error();
e(nil,{t,a,o});
end
end);
end
function e:delete_contact(i,n)
i=(type(i)=="table"and i.jid)or i;
local s={jid=i,subscription="remove"}
if not e.items[i]then return false,"item-not-found";end
t:send_iq(o.iq({type="set"})
:tag("query",{xmlns=a})
:add_child(h(s)),
function(e)
if not n then return end
if e.attr.type=="result"then
n(true);
else
local a,t,e=e:get_error();
n(nil,{a,t,e});
end
end);
end
local function h(t)
local t=d(t);
e.items[t.jid]=t;
end
local function d(t)
local a=e.items[t];
e.items[t]=nil;
return a;
end
function e:fetch(i)
t:send_iq(o.iq({type="get"}):tag("query",{xmlns=a,ver=s and e.ver or nil}),
function(t)
if t.attr.type=="result"then
local t=t:get_child("query",a);
if t then
e.items={};
for t in t:childtags("item")do
h(t)
end
e.ver=t.attr.ver or"";
end
i(e);
else
local t,e,a=stanza:get_error();
i(nil,{t,e,a});
end
end);
end
t:hook("iq/"..a,function(i)
local s,n=i.attr.type,i.attr.from;
if s=="set"and(not n or n==r(t.jid))then
local s=i:get_child("query",a);
local n=s and s:get_child("item");
if n then
local i,a;
local o=n.attr.jid;
if n.attr.subscription=="remove"then
i="removed"
a=d(o);
else
i=e.items[o]and"changed"or"added";
h(n)
a=e.items[o];
end
e.ver=s.attr.ver;
if a then
t:event("roster/item-"..i,a);
end
end
t:send(o.reply(i))
return true;
end
end);
end
end)
package.preload['verse.plugins.register']=(function(...)
local t=require"verse";
local i="jabber:iq:register";
function t.plugins.register(e)
local function a(o)
if o:get_child("register","http://jabber.org/features/iq-register")then
local t=t.iq({to=e.host_,type="set"})
:tag("query",{xmlns=i})
:tag("username"):text(e.username):up()
:tag("password"):text(e.password):up();
if e.register_email then
t:tag("email"):text(e.register_email):up();
end
e:send_iq(t,function(t)
if t.attr.type=="result"then
e:event("registration-success");
else
local o,t,a=t:get_error();
e:debug("Registration failed: %s",t);
e:event("registration-failure",{type=o,condition=t,text=a});
end
end);
else
e:debug("In-band registration not offered by server");
e:event("registration-failure",{condition="service-unavailable"});
end
e:unhook("stream-features",a);
return true;
end
e:hook("stream-features",a,310);
end
end)
package.preload['verse.plugins.groupchat']=(function(...)
local i=require"verse";
local e=require"events";
local n=require"util.jid";
local a={};
a.__index=a;
local h="urn:xmpp:delay";
local s="http://jabber.org/protocol/muc";
function i.plugins.groupchat(o)
o:add_plugin("presence")
o.rooms={};
o:hook("stanza",function(e)
local a=n.bare(e.attr.from);
if not a then return end
local t=o.rooms[a]
if not t and e.attr.to and a then
t=o.rooms[e.attr.to.." "..a]
end
if t and t.opts.source and e.attr.to~=t.opts.source then return end
if t then
local i=select(3,n.split(e.attr.from));
local n=e:get_child_text("body");
local o=e:get_child("delay",h);
local a={
room_jid=a;
room=t;
sender=t.occupants[i];
nick=i;
body=n;
stanza=e;
delay=(o and o.attr.stamp);
};
local t=t:event(e.name,a);
return t or(e.name=="message")or nil;
end
end,500);
function o:join_room(n,h,t)
if not h then
return false,"no nickname supplied"
end
t=t or{};
local e=setmetatable(i.eventable{
stream=o,jid=n,nick=h,
subject=nil,
occupants={},
opts=t,
},a);
if t.source then
self.rooms[t.source.." "..n]=e;
else
self.rooms[n]=e;
end
local a=e.occupants;
e:hook("presence",function(o)
local t=o.nick or h;
if not a[t]and o.stanza.attr.type~="unavailable"then
a[t]={
nick=t;
jid=o.stanza.attr.from;
presence=o.stanza;
};
local o=o.stanza:get_child("x",s.."#user");
if o then
local e=o:get_child("item");
if e and e.attr then
a[t].real_jid=e.attr.jid;
a[t].affiliation=e.attr.affiliation;
a[t].role=e.attr.role;
end
end
if t==e.nick then
e.stream:event("groupchat/joined",e);
else
e:event("occupant-joined",a[t]);
end
elseif a[t]and o.stanza.attr.type=="unavailable"then
if t==e.nick then
e.stream:event("groupchat/left",e);
if e.opts.source then
self.rooms[e.opts.source.." "..n]=nil;
else
self.rooms[n]=nil;
end
else
a[t].presence=o.stanza;
e:event("occupant-left",a[t]);
a[t]=nil;
end
end
end);
e:hook("message",function(a)
local t=a.stanza:get_child_text("subject");
if not t then return end
t=#t>0 and t or nil;
if t~=e.subject then
local o=e.subject;
e.subject=t;
return e:event("subject-changed",{from=o,to=t,by=a.sender,event=a});
end
end,2e3);
local t=i.presence():tag("x",{xmlns=s}):reset();
self:event("pre-groupchat/joining",t);
e:send(t)
self:event("groupchat/joining",e);
return e;
end
o:hook("presence-out",function(e)
if not e.attr.to then
for a,t in pairs(o.rooms)do
t:send(e);
end
e.attr.to=nil;
end
end);
end
function a:send(e)
if e.name=="message"and not e.attr.type then
e.attr.type="groupchat";
end
if e.name=="presence"then
e.attr.to=self.jid.."/"..self.nick;
end
if e.attr.type=="groupchat"or not e.attr.to then
e.attr.to=self.jid;
end
if self.opts.source then
e.attr.from=self.opts.source
end
self.stream:send(e);
end
function a:send_message(e)
self:send(i.message():tag("body"):text(e));
end
function a:set_subject(e)
self:send(i.message():tag("subject"):text(e));
end
function a:leave(t)
self.stream:event("groupchat/leaving",self);
local e=i.presence({type="unavailable"});
if t then
e:tag("status"):text(t);
end
self:send(e);
end
function a:admin_set(e,t,a,o)
self:send(i.iq({type="set"})
:query(s.."#admin")
:tag("item",{nick=e,[t]=a})
:tag("reason"):text(o or""));
end
function a:set_role(e,t,a)
self:admin_set(e,"role",t,a);
end
function a:set_affiliation(a,t,e)
self:admin_set(a,"affiliation",t,e);
end
function a:kick(e,t)
self:set_role(e,"none",t);
end
function a:ban(t,e)
self:set_affiliation(t,"outcast",e);
end
end)
package.preload['verse.plugins.vcard']=(function(...)
local i=require"verse";
local o=require"util.vcard";
local n="vcard-temp";
function i.plugins.vcard(a)
function a:get_vcard(t,e)
a:send_iq(i.iq({to=t,type="get"})
:tag("vCard",{xmlns=n}),e and function(t)
local a,a;
vCard=t:get_child("vCard",n);
if t.attr.type=="result"and vCard then
vCard=o.from_xep54(vCard)
e(vCard)
else
e(false)
end
end or nil);
end
function a:set_vcard(e,n)
local t;
if type(e)=="table"and e.name then
t=e;
elseif type(e)=="string"then
t=o.to_xep54(o.from_text(e)[1]);
elseif type(e)=="table"then
t=o.to_xep54(e);
error("Converting a table to vCard not implemented")
end
if not t then return false end
a:debug("setting vcard to %s",tostring(t));
a:send_iq(i.iq({type="set"})
:add_child(t),n);
end
end
end)
package.preload['verse.plugins.vcard_update']=(function(...)
local i=require"verse";
local e,n="vcard-temp","vcard-temp:x:update";
local e,t=pcall(function()return require("util.hashes").sha1;end);
if not e then
e,t=pcall(function()return require("util.sha1").sha1;end);
if not e then
error("Could not find a sha1()")
end
end
local h=t;
local e,t=pcall(function()
local e=require("util.encodings").base64.decode;
assert(e("SGVsbG8=")=="Hello")
return e;
end);
if not e then
e,t=pcall(function()return require("mime").unb64;end);
if not e then
error("Could not find a base64 decoder")
end
end
local s=t;
function i.plugins.vcard_update(e)
e:add_plugin("vcard");
e:add_plugin("presence");
local t;
function update_vcard_photo(a)
local o;
for e=1,#a do
if a[e].name=="PHOTO"then
o=a[e][1];
break
end
end
if o then
local a=h(s(o),true);
t=i.stanza("x",{xmlns=n})
:tag("photo"):text(a);
e:resend_presence()
else
t=nil;
end
end
local a=e.set_vcard;
local a;
e:hook("ready",function(t)
if a then return;end
a=true;
e:get_vcard(nil,function(t)
if t then
update_vcard_photo(t)
end
e:event("ready");
end);
return true;
end,3);
e:hook("presence-out",function(e)
if t and not e:get_child("x",n)then
e:add_child(t);
end
end,10);
end
end)
package.preload['verse.plugins.carbons']=(function(...)
local a=require"verse";
local o="urn:xmpp:carbons:2";
local h="urn:xmpp:forward:0";
local r=os.time;
local s=require"util.datetime".parse;
local n=require"util.jid".bare;
function a.plugins.carbons(e)
local t={};
t.enabled=false;
e.carbons=t;
function t:enable(i)
e:send_iq(a.iq{type="set"}
:tag("enable",{xmlns=o})
,function(e)
local e=e.attr.type=="result";
if e then
t.enabled=true;
end
if i then
i(e);
end
end or nil);
end
function t:disable(i)
e:send_iq(a.iq{type="set"}
:tag("disable",{xmlns=o})
,function(e)
local e=e.attr.type=="result";
if e then
t.enabled=false;
end
if i then
i(e);
end
end or nil);
end
local a;
e:hook("bind-success",function()
a=n(e.jid);
end);
e:hook("message",function(i)
local t=i:get_child(nil,o);
if i.attr.from==a and t then
local o=t.name;
local t=t:get_child("forwarded",h);
local a=t and t:get_child("message","jabber:client");
local t=t:get_child("delay","urn:xmpp:delay");
local t=t and t.attr.stamp;
t=t and s(t);
if a then
return e:event("carbon",{
dir=o,
stanza=a,
timestamp=t or r(),
});
end
end
end,1);
end
end)
package.preload['verse.plugins.archive']=(function(...)
local e=require"verse";
local a=require"util.stanza";
local t="urn:xmpp:mam:0"
local r="urn:xmpp:forward:0";
local l="urn:xmpp:delay";
local s=require"util.uuid".generate;
local u=require"util.datetime".parse;
local i=require"util.datetime".datetime;
local o=require"util.dataforms".new;
local d=require"util.rsm";
local m={};
local c=o{
{name="FORM_TYPE";type="hidden";value=t;};
{name="with";type="jid-single";};
{name="start";type="text-single"};
{name="end";type="text-single";};
};
function e.plugins.archive(n)
function n:query_archive(o,e,h)
local s=s();
local n=a.iq{type="set",to=o}
:tag("query",{xmlns=t,queryid=s});
local o,a=tonumber(e["start"]),tonumber(e["end"]);
e["start"]=o and i(o);
e["end"]=a and i(a);
n:add_child(c:form(e,"submit"));
n:add_child(d.generate(e));
local a={};
local function o(i)
local e=i:get_child("fin",t)
if e and e.attr.queryid==s then
local e=d.get(e);
for e,t in pairs(e or m)do a[e]=t;end
self:unhook("message",o);
h(a);
return true
end
local e=i:get_child("result",t);
if e and e.attr.queryid==s then
local t=e:get_child("forwarded",r);
t=t or i:get_child("forwarded",r);
local o=e.attr.id;
local e=t:get_child("delay",l);
local i=e and u(e.attr.stamp)or nil;
local e=t:get_child("message","jabber:client")
a[#a+1]={id=o,stamp=i,message=e};
return true
end
end
self:hook("message",o,1);
self:send_iq(n,function(e)
if e.attr.type=="error"then
self:warn(table.concat({e:get_error()}," "))
self:unhook("message",o);
h(false,e:get_error())
end
return true
end);
end
local i={
always=true,[true]="always",
never=false,[false]="never",
roster="roster",
}
local function h(t)
local e={};
local a=t.attr.default;
if a then
e[false]=i[a];
end
local a=t:get_child("always");
if a then
for t in a:childtags("jid")do
local t=t:get_text();
e[t]=true;
end
end
local t=t:get_child("never");
if t then
for t in t:childtags("jid")do
local t=t:get_text();
e[t]=false;
end
end
return e;
end
local function s(o)
local e
e,o[false]=o[false],nil;
if e~=nil then
e=i[e];
end
local i=a.stanza("prefs",{xmlns=t,default=e})
local t=a.stanza("always");
local e=a.stanza("never");
for o,a in pairs(o)do
(a and t or e):tag("jid"):text(o):up();
end
return i:add_child(t):add_child(e);
end
function n:archive_prefs_get(o)
self:send_iq(a.iq{type="get"}:tag("prefs",{xmlns=t}),
function(e)
if e and e.attr.type=="result"and e.tags[1]then
local t=h(e.tags[1]);
o(t,e);
else
o(nil,e);
end
end);
end
function n:archive_prefs_set(t,e)
self:send_iq(a.iq{type="set"}:add_child(s(t)),e);
end
end
end)
package.preload['util.http']=(function(...)
local t,s=string.format,string.char;
local i,n,h=pairs,ipairs,tonumber;
local o,r=table.insert,table.concat;
local function d(e)
return e and(e:gsub("[^a-zA-Z0-9.~_-]",function(e)return t("%%%02x",e:byte());end));
end
local function a(e)
return e and(e:gsub("%%(%x%x)",function(e)return s(h(e,16));end));
end
local function e(e)
return e and(e:gsub("%W",function(e)
if e~=" "then
return t("%%%02x",e:byte());
else
return"+";
end
end));
end
local function s(t)
local a={};
if t[1]then
for i,t in n(t)do
o(a,e(t.name).."="..e(t.value));
end
else
for t,i in i(t)do
o(a,e(t).."="..e(i));
end
end
return r(a,"&");
end
local function n(e)
if not e:match("=")then return a(e);end
local i={};
for e,t in e:gmatch("([^=&]*)=([^&]*)")do
e,t=e:gsub("%+","%%20"),t:gsub("%+","%%20");
e,t=a(e),a(t);
o(i,{name=e,value=t});
i[e]=t;
end
return i;
end
local function o(e,t)
e=","..e:gsub("[ \t]",""):lower()..",";
return e:find(","..t:lower()..",",1,true)~=nil;
end
return{
urlencode=d,urldecode=a;
formencode=s,formdecode=n;
contains_token=o;
};
end)
package.preload['net.http.parser']=(function(...)
local w=tonumber;
local a=assert;
local b=require"socket.url".parse;
local t=require"util.http".urldecode;
local function g(e)
e=t((e:gsub("//+","/")));
if e:sub(1,1)~="/"then
e="/"..e;
end
local t=0;
for e in e:gmatch("([^/]+)/")do
if e==".."then
t=t-1;
elseif e~="."then
t=t+1;
end
if t<0 then
return nil;
end
end
return e;
end
local v={};
function v.new(u,s,e,y)
local d=true;
if not e or e=="server"then d=false;else a(e=="client","Invalid parser type");end
local e="";
local p,a,r;
local h=nil;
local t;
local o;
local c;
local n;
return{
feed=function(l,i)
if n then return nil,"parse has failed";end
if not i then
if h and d and not o then
t.body=e;
u(t);
elseif e~=""then
n=true;return s();
end
return;
end
e=e..i;
while#e>0 do
if h==nil then
local f=e:find("\r\n\r\n",nil,true);
if not f then return;end
local m,r,l,i,v;
local u;
local a={};
for t in e:sub(1,f+1):gmatch("([^\r\n]+)\r\n")do
if u then
local e,t=t:match("^([^%s:]+): *(.*)$");
if not e then n=true;return s("invalid-header-line");end
e=e:lower();
a[e]=a[e]and a[e]..","..t or t;
else
u=t;
if d then
l,i,v=t:match("^HTTP/(1%.[01]) (%d%d%d) (.*)$");
i=w(i);
if not i then n=true;return s("invalid-status-line");end
c=not
((y and y().method=="HEAD")
or(i==204 or i==304 or i==301)
or(i>=100 and i<200));
else
m,r,l=t:match("^(%w+) (%S+) HTTP/(1%.[01])$");
if not m then n=true;return s("invalid-status-line");end
end
end
end
if not u then n=true;return s("invalid-status-line");end
p=c and a["transfer-encoding"]=="chunked";
o=w(a["content-length"]);
if d then
if not c then o=0;end
t={
code=i;
httpversion=l;
headers=a;
body=c and""or nil;
responseversion=l;
responseheaders=a;
};
else
local e;
if r:byte()==47 then
local a,t=r:match("([^?]*).?(.*)");
if t==""then t=nil;end
e={path=a,query=t};
else
e=b(r);
if not(e and e.path)then n=true;return s("invalid-url");end
end
r=g(e.path);
a.host=e.host or a.host;
o=o or 0;
t={
method=m;
url=e;
path=r;
httpversion=l;
headers=a;
body=nil;
};
end
e=e:sub(f+4);
h=true;
end
if h then
if d then
if p then
if not e:find("\r\n",nil,true)then
return;
end
if not a then
a,r=e:match("^(%x+)[^\r\n]*\r\n()");
a=a and w(a,16);
if not a then n=true;return s("invalid-chunk-size");end
end
if a==0 and e:find("\r\n\r\n",r-2,true)then
h,a=nil,nil;
e=e:gsub("^.-\r\n\r\n","");
u(t);
elseif#e-r-2>=a then
t.body=t.body..e:sub(r,r+(a-1));
e=e:sub(r+a+2);
a,r=nil,nil;
else
break;
end
elseif o and#e>=o then
if t.code==101 then
t.body,e=e,"";
else
t.body,e=e:sub(1,o),e:sub(o+1);
end
h=nil;u(t);
else
break;
end
elseif#e>=o then
t.body,e=e:sub(1,o),e:sub(o+1);
h=nil;u(t);
else
break;
end
end
end
end;
};
end
return v;
end)
package.preload['net.http']=(function(...)
local x=require"socket"
local j=require"util.encodings".base64.encode;
local c=require"socket.url"
local d=require"net.http.parser".new;
local h=require"util.http";
local w=pcall(require,"ssl");
local f=require"net.server"
local r,i=table.insert,table.concat;
local m=pairs;
local y,u,b,p,s=
tonumber,tostring,xpcall,select,debug.traceback;
local g,v=assert,error
local l=require"util.logger".init("http");
module"http"
local o={};
local n={default_port=80,default_mode="*a"};
function n.onconnect(t)
local e=o[t];
local a={e.method or"GET"," ",e.path," HTTP/1.1\r\n"};
if e.query then
r(a,4,"?"..e.query);
end
t:write(i(a));
local a={[2]=": ",[4]="\r\n"};
for o,e in m(e.headers)do
a[1],a[3]=o,e;
t:write(i(a));
end
t:write("\r\n");
if e.body then
t:write(e.body);
end
end
function n.onincoming(t,a)
local e=o[t];
if not e then
l("warn","Received response from connection %s with no request attached!",u(t));
return;
end
if a and e.reader then
e:reader(a);
end
end
function n.ondisconnect(t,a)
local e=o[t];
if e and e.conn then
e:reader(nil,a);
end
o[t]=nil;
end
function n.ondetach(e)
o[e]=nil;
end
local function q(e,a,i)
if not e.parser then
local function o(t)
if e.callback then
e.callback(t or"connection-closed",0,e);
e.callback=nil;
end
destroy_request(e);
end
if not a then
o(i);
return;
end
local function a(t)
if e.callback then
e.callback(t.body,t.code,t,e);
e.callback=nil;
end
destroy_request(e);
end
local function t()
return e;
end
e.parser=d(a,o,"client",t);
end
e.parser:feed(a);
end
local function k(e)l("error","Traceback[http]: %s",s(u(e),2));end
function request(e,t,d)
local e=c.parse(e);
if not(e and e.host)then
d(nil,0,e);
return nil,"invalid-url";
end
if not e.path then
e.path="/";
end
local r,i,s;
local c,a=e.host,e.port;
local h=c;
if(a=="80"and e.scheme=="http")
or(a=="443"and e.scheme=="https")then
a=nil;
elseif a then
h=h..":"..a;
end
i={
["Host"]=h;
["User-Agent"]="Prosody XMPP Server";
};
if e.userinfo then
i["Authorization"]="Basic "..j(e.userinfo);
end
if t then
e.onlystatus=t.onlystatus;
s=t.body;
if s then
r="POST";
i["Content-Length"]=u(#s);
i["Content-Type"]="application/x-www-form-urlencoded";
end
if t.method then r=t.method;end
if t.headers then
for e,t in m(t.headers)do
i[e]=t;
end
end
end
e.method,e.headers,e.body=r,i,s;
local i=e.scheme=="https";
if i and not w then
v("SSL not available, unable to contact https URL");
end
local h=a and y(a)or(i and 443 or 80);
local a=x.tcp();
a:settimeout(10);
local r,s=a:connect(c,h);
if not r and s~="timeout"then
d(nil,0,e);
return nil,s;
end
local s=false;
if i then
s=t and t.sslctx or{mode="client",protocol="sslv23",options={"no_sslv2","no_sslv3"}};
end
e.handler,e.conn=g(f.wrapclient(a,c,h,n,"*a",s));
e.write=function(...)return e.handler:write(...);end
e.callback=function(o,t,i,a)l("debug","Calling callback, status %s",t or"---");return p(2,b(function()return d(o,t,i,a)end,k));end
e.reader=q;
e.state="status";
o[e.handler]=e;
return e;
end
function destroy_request(e)
if e.conn then
e.conn=nil;
e.handler:close()
end
end
local t,o=h.urlencode,h.urldecode;
local a,e=h.formencode,h.formdecode;
_M.urlencode,_M.urldecode=t,o;
_M.formencode,_M.formdecode=a,e;
return _M;
end)
package.preload['verse.bosh']=(function(...)
local n=require"util.xmppstream".new;
local i=require"util.stanza";
require"net.httpclient_listener";
local o=require"net.http";
local e=setmetatable({},{__index=verse.stream_mt});
e.__index=e;
local s="http://etherx.jabber.org/streams";
local h="http://jabber.org/protocol/httpbind";
local a=5;
function verse.new_bosh(a,t)
local t={
bosh_conn_pool={};
bosh_waiting_requests={};
bosh_rid=math.random(1,999999);
bosh_outgoing_buffer={};
bosh_url=t;
conn={};
};
function t:reopen()
self.bosh_need_restart=true;
self:flush();
end
local t=verse.new(a,t);
return setmetatable(t,e);
end
function e:connect()
self:_send_session_request();
end
function e:send(e)
self:debug("Putting into BOSH send buffer: %s",tostring(e));
self.bosh_outgoing_buffer[#self.bosh_outgoing_buffer+1]=i.clone(e);
self:flush();
end
function e:flush()
if self.connected
and#self.bosh_waiting_requests<self.bosh_max_requests
and(#self.bosh_waiting_requests==0
or#self.bosh_outgoing_buffer>0
or self.bosh_need_restart)then
self:debug("Flushing...");
local t=self:_make_body();
local e=self.bosh_outgoing_buffer;
for a,o in ipairs(e)do
t:add_child(o);
e[a]=nil;
end
self:_make_request(t);
else
self:debug("Decided not to flush.");
end
end
function e:_make_request(i)
local e,t=o.request(self.bosh_url,{body=tostring(i)},function(o,e,t)
if e~=0 then
self.inactive_since=nil;
return self:_handle_response(o,e,t);
end
local e=os.time();
if not self.inactive_since then
self.inactive_since=e;
elseif e-self.inactive_since>self.bosh_max_inactivity then
return self:_disconnected();
else
self:debug("%d seconds left to reconnect, retrying in %d seconds...",
self.bosh_max_inactivity-(e-self.inactive_since),a);
end
timer.add_task(a,function()
self:debug("Retrying request...");
for e,a in ipairs(self.bosh_waiting_requests)do
if a==t then
table.remove(self.bosh_waiting_requests,e);
break;
end
end
self:_make_request(i);
end);
end);
if e then
table.insert(self.bosh_waiting_requests,e);
else
self:warn("Request failed instantly: %s",t);
end
end
function e:_disconnected()
self.connected=nil;
self:event("disconnected");
end
function e:_send_session_request()
local e=self:_make_body();
e.attr.hold="1";
e.attr.wait="60";
e.attr["xml:lang"]="en";
e.attr.ver="1.6";
e.attr.from=self.jid;
e.attr.to=self.host;
e.attr.secure='true';
o.request(self.bosh_url,{body=tostring(e)},function(e,t)
if t==0 then
return self:_disconnected();
end
local e=self:_parse_response(e)
if not e then
self:warn("Invalid session creation response");
self:_disconnected();
return;
end
self.bosh_sid=e.attr.sid;
self.bosh_wait=tonumber(e.attr.wait);
self.bosh_hold=tonumber(e.attr.hold);
self.bosh_max_inactivity=tonumber(e.attr.inactivity);
self.bosh_max_requests=tonumber(e.attr.requests)or self.bosh_hold;
self.connected=true;
self:event("connected");
self:_handle_response_payload(e);
end);
end
function e:_handle_response(t,a,e)
if self.bosh_waiting_requests[1]~=e then
self:warn("Server replied to request that wasn't the oldest");
for a,t in ipairs(self.bosh_waiting_requests)do
if t==e then
self.bosh_waiting_requests[a]=nil;
break;
end
end
else
table.remove(self.bosh_waiting_requests,1);
end
local e=self:_parse_response(t);
if e then
self:_handle_response_payload(e);
end
self:flush();
end
function e:_handle_response_payload(t)
local e=t.tags;
for t=1,#e do
local e=e[t];
if e.attr.xmlns==s then
self:event("stream-"..e.name,e);
elseif e.attr.xmlns then
self:event("stream/"..e.attr.xmlns,e);
else
self:event("stanza",e);
end
end
if t.attr.type=="terminate"then
self:_disconnected({reason=t.attr.condition});
end
end
local a={
stream_ns="http://jabber.org/protocol/httpbind",stream_tag="body",
default_ns="jabber:client",
streamopened=function(e,t)e.notopen=nil;e.payload=verse.stanza("body",t);return true;end;
handlestanza=function(e,t)e.payload:add_child(t);end;
};
function e:_parse_response(e)
self:debug("Parsing response: %s",e);
if e==nil then
self:debug("%s",debug.traceback());
self:_disconnected();
return;
end
local t={notopen=true,stream=self};
local a=n(t,a);
a:feed(e);
return t.payload;
end
function e:_make_body()
self.bosh_rid=self.bosh_rid+1;
local e=verse.stanza("body",{
xmlns=h;
content="text/xml; charset=utf-8";
sid=self.bosh_sid;
rid=self.bosh_rid;
});
if self.bosh_need_restart then
self.bosh_need_restart=nil;
e.attr.restart='true';
end
return e;
end
end)
package.preload['verse.client']=(function(...)
local t=require"verse";
local i=t.stream_mt;
local s=require"util.jid".split;
local r=require"net.adns";
local e=require"lxp";
local a=require"util.stanza";
t.message,t.presence,t.iq,t.stanza,t.reply,t.error_reply=
a.message,a.presence,a.iq,a.stanza,a.reply,a.error_reply;
local h=require"util.xmppstream".new;
local n="http://etherx.jabber.org/streams";
local function d(t,e)
return t.priority<e.priority or(t.priority==e.priority and t.weight>e.weight);
end
local o={
stream_ns=n,
stream_tag="stream",
default_ns="jabber:client"};
function o.streamopened(e,t)
e.stream_id=t.id;
if not e:event("opened",t)then
e.notopen=nil;
end
return true;
end
function o.streamclosed(e)
e.notopen=true;
if not e.closed then
e:send("</stream:stream>");
e.closed=true;
end
e:event("closed");
return e:close("stream closed")
end
function o.handlestanza(t,e)
if e.attr.xmlns==n then
return t:event("stream-"..e.name,e);
elseif e.attr.xmlns then
return t:event("stream/"..e.attr.xmlns,e);
end
return t:event("stanza",e);
end
function o.error(a,t,e)
if a:event(t,e)==nil then
if e then
local t=e:get_child(nil,"urn:ietf:params:xml:ns:xmpp-streams");
local e=e:get_child_text("text","urn:ietf:params:xml:ns:xmpp-streams");
error(t.name..(e and": "..e or""));
else
error(e and e.name or t or"unknown-error");
end
end
end
function i:reset()
if self.stream then
self.stream:reset();
else
self.stream=h(self,o);
end
self.notopen=true;
return true;
end
function i:connect_client(e,a)
self.jid,self.password=e,a;
self.username,self.host,self.resource=s(e);
self:add_plugin("tls");
self:add_plugin("sasl");
self:add_plugin("bind");
self:add_plugin("session");
function self.data(t,e)
local t,a=self.stream:feed(e);
if t then return;end
self:debug("debug","Received invalid XML (%s) %d bytes: %s",tostring(a),#e,e:sub(1,300):gsub("[\r\n]+"," "));
self:close("xml-not-well-formed");
end
self:hook("connected",function()self:reopen();end);
self:hook("incoming-raw",function(e)return self.data(self.conn,e);end);
self.curr_id=0;
self.tracked_iqs={};
self:hook("stanza",function(e)
local t,a=e.attr.id,e.attr.type;
if t and e.name=="iq"and(a=="result"or a=="error")and self.tracked_iqs[t]then
self.tracked_iqs[t](e);
self.tracked_iqs[t]=nil;
return true;
end
end);
self:hook("stanza",function(e)
local a;
if e.attr.xmlns==nil or e.attr.xmlns=="jabber:client"then
if e.name=="iq"and(e.attr.type=="get"or e.attr.type=="set")then
local o=e.tags[1]and e.tags[1].attr.xmlns;
if o then
a=self:event("iq/"..o,e);
if not a then
a=self:event("iq",e);
end
end
if a==nil then
self:send(t.error_reply(e,"cancel","service-unavailable"));
return true;
end
else
a=self:event(e.name,e);
end
end
return a;
end,-1);
self:hook("outgoing",function(e)
if e.name then
self:event("stanza-out",e);
end
end);
self:hook("stanza-out",function(e)
if not e.attr.xmlns then
self:event(e.name.."-out",e);
end
end);
local function e()
self:event("ready");
end
self:hook("session-success",e,-1)
self:hook("bind-success",e,-1);
local e=self.close;
function self:close(t)
self.close=e;
if not self.closed then
self:send("</stream:stream>");
self.closed=true;
else
return self:close(t);
end
end
local function t()
self:connect(self.connect_host or self.host,self.connect_port or 5222);
end
if not(self.connect_host or self.connect_port)then
r.lookup(function(a)
if a then
local e={};
self.srv_hosts=e;
for a,t in ipairs(a)do
table.insert(e,t.srv);
end
table.sort(e,d);
local a=e[1];
self.srv_choice=1;
if a then
self.connect_host,self.connect_port=a.target,a.port;
self:debug("Best record found, will connect to %s:%d",self.connect_host or self.host,self.connect_port or 5222);
end
self:hook("disconnected",function()
if self.srv_hosts and self.srv_choice<#self.srv_hosts then
self.srv_choice=self.srv_choice+1;
local e=e[self.srv_choice];
self.connect_host,self.connect_port=e.target,e.port;
t();
return true;
end
end,1e3);
self:hook("connected",function()
self.srv_hosts=nil;
end,1e3);
end
t();
end,"_xmpp-client._tcp."..(self.host)..".","SRV");
else
t();
end
end
function i:reopen()
self:reset();
self:send(a.stanza("stream:stream",{to=self.host,["xmlns:stream"]='http://etherx.jabber.org/streams',
xmlns="jabber:client",version="1.0"}):top_tag());
end
function i:send_iq(t,a)
local e=self:new_id();
self.tracked_iqs[e]=a;
t.attr.id=e;
self:send(t);
end
function i:new_id()
self.curr_id=self.curr_id+1;
return tostring(self.curr_id);
end
end)
package.preload['verse.component']=(function(...)
local o=require"verse";
local a=o.stream_mt;
local h=require"util.jid".split;
local e=require"lxp";
local t=require"util.stanza";
local d=require"util.sha1".sha1;
o.message,o.presence,o.iq,o.stanza,o.reply,o.error_reply=
t.message,t.presence,t.iq,t.stanza,t.reply,t.error_reply;
local r=require"util.xmppstream".new;
local s="http://etherx.jabber.org/streams";
local i="jabber:component:accept";
local n={
stream_ns=s,
stream_tag="stream",
default_ns=i};
function n.streamopened(e,t)
e.stream_id=t.id;
if not e:event("opened",t)then
e.notopen=nil;
end
return true;
end
function n.streamclosed(e)
return e:event("closed");
end
function n.handlestanza(t,e)
if e.attr.xmlns==s then
return t:event("stream-"..e.name,e);
elseif e.attr.xmlns or e.name=="handshake"then
return t:event("stream/"..(e.attr.xmlns or i),e);
end
return t:event("stanza",e);
end
function a:reset()
if self.stream then
self.stream:reset();
else
self.stream=r(self,n);
end
self.notopen=true;
return true;
end
function a:connect_component(e,n)
self.jid,self.password=e,n;
self.username,self.host,self.resource=h(e);
function self.data(t,e)
local o,t=self.stream:feed(e);
if o then return;end
a:debug("debug","Received invalid XML (%s) %d bytes: %s",tostring(t),#e,e:sub(1,300):gsub("[\r\n]+"," "));
a:close("xml-not-well-formed");
end
self:hook("incoming-raw",function(e)return self.data(self.conn,e);end);
self.curr_id=0;
self.tracked_iqs={};
self:hook("stanza",function(t)
local e,a=t.attr.id,t.attr.type;
if e and t.name=="iq"and(a=="result"or a=="error")and self.tracked_iqs[e]then
self.tracked_iqs[e](t);
self.tracked_iqs[e]=nil;
return true;
end
end);
self:hook("stanza",function(e)
local t;
if e.attr.xmlns==nil or e.attr.xmlns=="jabber:client"then
if e.name=="iq"and(e.attr.type=="get"or e.attr.type=="set")then
local a=e.tags[1]and e.tags[1].attr.xmlns;
if a then
t=self:event("iq/"..a,e);
if not t then
t=self:event("iq",e);
end
end
if t==nil then
self:send(o.error_reply(e,"cancel","service-unavailable"));
return true;
end
else
t=self:event(e.name,e);
end
end
return t;
end,-1);
self:hook("opened",function(e)
print(self.jid,self.stream_id,e.id);
local e=d(self.stream_id..n,true);
self:send(t.stanza("handshake",{xmlns=i}):text(e));
self:hook("stream/"..i,function(e)
if e.name=="handshake"then
self:event("authentication-success");
end
end);
end);
local function e()
self:event("ready");
end
self:hook("authentication-success",e,-1);
self:connect(self.connect_host or self.host,self.connect_port or 5347);
self:reopen();
end
function a:reopen()
self:reset();
self:send(t.stanza("stream:stream",{to=self.jid,["xmlns:stream"]='http://etherx.jabber.org/streams',
xmlns=i,version="1.0"}):top_tag());
end
function a:close(t)
if not self.notopen then
self:send("</stream:stream>");
end
local e=self.conn.disconnect();
self.conn:close();
e(conn,t);
end
function a:send_iq(t,a)
local e=self:new_id();
self.tracked_iqs[e]=a;
t.attr.id=e;
self:send(t);
end
function a:new_id()
self.curr_id=self.curr_id+1;
return tostring(self.curr_id);
end
end)
pcall(require,"luarocks.require");
local s=require"socket";
pcall(require,"ssl");
local a=require"net.server";
local n=require"util.events";
local o=require"util.logger";
module("verse",package.seeall);
local e=_M;
_M.server=a;
local t={};
t.__index=t;
stream_mt=t;
e.plugins={};
function e.init(...)
for e=1,select("#",...)do
local t=pcall(require,"verse."..select(e,...));
if not t then
error("Verse connection module not found: verse."..select(e,...));
end
end
return e;
end
local i=0;
function e.new(a,o)
local t=setmetatable(o or{},t);
i=i+1;
t.id=tostring(i);
t.logger=a or e.new_logger("stream"..t.id);
t.events=n.new();
t.plugins={};
t.verse=e;
return t;
end
e.add_task=require"util.timer".add_task;
e.logger=o.init;
e.new_logger=o.init;
e.log=e.logger("verse");
local function h(o,...)
local e,t,a=0,{...},select('#',...);
return(o:gsub("%%(.)",function(o)if e<=a then e=e+1;return tostring(t[e]);end end));
end
function e.set_log_handler(e,t)
t=t or{"debug","info","warn","error"};
o.reset();
if io.type(e)=="file"then
local o=e;
function e(a,t,e)
o:write(a,"\t",t,"\t",e,"\n");
end
end
if e then
local function i(a,t,o,...)
return e(a,t,h(o,...));
end
for t,e in ipairs(t)do
o.add_level_sink(e,i);
end
end
end
function _default_log_handler(a,t,o)
return io.stderr:write(a,"\t",t,"\t",o,"\n");
end
e.set_log_handler(_default_log_handler,{"error"});
local function o(t)
e.log("error","Error: %s",t);
e.log("error","Traceback: %s",debug.traceback());
end
function e.set_error_handler(e)
o=e;
end
function e.loop()
return xpcall(a.loop,o);
end
function e.step()
return xpcall(a.step,o);
end
function e.quit()
return a.setquitting(true);
end
function t:listen(e,t)
e=e or"localhost";
t=t or 0;
local a,o=a.addserver(e,t,new_listener(self,"server"),"*a");
if a then
self:debug("Bound to %s:%s",e,t);
self.server=a;
end
return a,o;
end
function t:connect(t,o)
t=t or"localhost";
o=tonumber(o)or 5222;
local i=s.tcp()
i:settimeout(0);
local n,e=i:connect(t,o);
if not n and e~="timeout"then
self:warn("connect() to %s:%d failed: %s",t,o,e);
return self:event("disconnected",{reason=e})or false,e;
end
local t=a.wrapclient(i,t,o,new_listener(self),"*a");
if not t then
self:warn("connection initialisation failed: %s",e);
return self:event("disconnected",{reason=e})or false,e;
end
self:set_conn(t);
return true;
end
function t:set_conn(t)
self.conn=t;
self.send=function(a,e)
self:event("outgoing",e);
e=tostring(e);
self:event("outgoing-raw",e);
return t:write(e);
end;
end
function t:close(t)
if not self.conn then
e.log("error","Attempt to close disconnected connection - possibly a bug");
return;
end
local e=self.conn.disconnect();
self.conn:close();
e(self.conn,t);
end
function t:debug(...)
return self.logger("debug",...);
end
function t:info(...)
return self.logger("info",...);
end
function t:warn(...)
return self.logger("warn",...);
end
function t:error(...)
return self.logger("error",...);
end
function t:event(e,...)
self:debug("Firing event: "..tostring(e));
return self.events.fire_event(e,...);
end
function t:hook(e,...)
return self.events.add_handler(e,...);
end
function t:unhook(e,t)
return self.events.remove_handler(e,t);
end
function e.eventable(e)
e.events=n.new();
e.hook,e.unhook=t.hook,t.unhook;
local t=e.events.fire_event;
function e:event(e,...)
return t(e,...);
end
return e;
end
function t:add_plugin(t)
if self.plugins[t]then return true;end
if require("verse.plugins."..t)then
local e,a=e.plugins[t](self);
if e~=false then
self:debug("Loaded %s plugin",t);
self.plugins[t]=true;
else
self:warn("Failed to load %s plugin: %s",t,a);
end
end
return self;
end
function new_listener(t)
local a={};
function a.onconnect(a)
if t.server then
local e=e.new();
a:setlistener(new_listener(e));
e:set_conn(a);
t:event("connected",{client=e});
else
t.connected=true;
t:event("connected");
end
end
function a.onincoming(a,e)
t:event("incoming-raw",e);
end
function a.ondisconnect(e,a)
if e~=t.conn then return end
t.connected=false;
t:event("disconnected",{reason=a});
end
function a.ondrain(e)
t:event("drained");
end
function a.onstatus(a,e)
t:event("status",e);
end
return a;
end
return e;
end)
local e="jabber:client"
local e=require"net.server";
local e=require"core.portmanager";
local h,t,e,d=
module.host,nil,module:get_option_string("conference_server"),module:get_option_number("listener_port",7e3);
if not e then
module:log("error","You need to set the MUC server in the configuration (conference_server)!")
module:log("error","Be a good boy or girl and go read the wiki at: http://code.google.com/p/prosody-modules/wiki/mod_ircd")
return false;
end
package.loaded["util.sha1"]=require"util.encodings";
require"verse".init("component");
c=verse.new();
c:add_plugin("groupchat");
local function t(e)
return c:event("stanza",e.stanza)or true;
end
module:hook("message/bare",t);
module:hook("message/full",t);
module:hook("presence/bare",t);
module:hook("presence/full",t);
c.type="component";
c.send=core_post_stanza;
local s=require"util.jid";
local w=require"util.encodings".stringprep.nodeprep;
local function u(o)
local i,r=table.insert,table.concat;
local a,t={},1;
if not(o and#o>0)then
return""
end
while true do
local n=o:sub(t,t)
local e=n:byte();
local s=(
(e>=9 and e<=10 and 0)or
(e>=32 and e<=126 and 0)or
(e>=192 and e<=223 and 1)or
(e>=224 and e<=239 and 2)or
(e>=240 and e<=247 and 3)or
(e>=248 and e<=251 and 4)or
(e>=251 and e<=252 and 5)or nil
)
if not s then
i(a,"?")
else
local h=t+s;
if s==0 then
i(a,n);
elseif h>#o then
i(a,("?"):format(e));
else
local o=o:sub(t+1,h);
if o:match('^[\128-\191]*$')then
i(a,n);
i(a,o);
t=h;
else
i(a,("?"):format(e));
end
end
end
t=t+1;
if t>#o then
break
end
end
return r(a);
end
local function r(t)
local e={};
if t:sub(1,1)==":"then
e.from,t=t:match("^:(%w+)%s+(.*)$");
end
for a in t:gmatch("%S+")do
if a:sub(1,1)==":"then
e[#e+1]=t:match(":(.*)$");
break
end
e[#e+1]=a;
end
return e;
end
local function m(e)
if#e>1 then
e[#e]=":"..e[#e];
end
return(e.from and":"..e.from.." "or"")..table.concat(e," ");
end
local function b(t,a)
local t=t and w(t:match("^#(%w+)"))or nil;
if not a then
return s.join(t,e);
else
return s.join(t,e,a);
end
end
local function t(e)
local e,a,t=s.split(e);
return"#"..e,t;
end
local t={
moderator="@",
participant="",
visitor="",
none=""
}
local t={
owner="~",
administrator="&",
member="+",
none=""
}
local k={
moderator="o",
participant="",
visitor="",
none=""
}
local g={
owner="q",
administrator="a",
member="v",
none=""
}
local f={default_port=d,default_mode="*l";interface="192.168.1.3"};
local d=module:shared("sessions");
local i={};
local n={};
local o={};
local l={};
local p=require"util.stanza";
local t=e;
local function a(e)
e.conn:close();
end
function f.onincoming(o,i)
local t=d[o];
if not t then
t={conn=o,host=h,reset_stream=function()end,
close=a,log=logger.init("irc"..(o.id or"1")),
rooms={},roster={},has_un=false};
d[o]=t;
function t.data(a)
local o=r(a);
module:log("debug",require"util.serialization".serialize(o));
local a=table.remove(o,1);
if not a then
return;
end
a=a:upper();
if not t.username and not t.nick then
if not(a=="USER"or a=="NICK")then
module:log("debug","Client tried to send command %s before registering",a);
return t.send{from=e,"451",a,"You have not completed the registration."}
end
end
if n[a]then
local e=n[a](t,o);
if e then
return t.send(e);
end
else
t.send{from=e,"421",t.nick,a,"Unknown command"};
return module:log("debug","Unknown command: %s",a);
end
end
function t.send(e)
if type(e)=="string"then
return o:write(e.."\r\n");
elseif type(e)=="table"then
local e=m(e);
module:log("debug",e);
o:write(e.."\r\n");
end
end
end
if i then
t.data(i);
end
end
function f.ondisconnect(t,e)
local e=d[t];
if e then
for t,e in pairs(e.rooms)do
e:leave("Disconnected");
end
if e.nick then
o[e.nick]=nil;
end
if e.full_jid then
i[e.full_jid]=nil;
end
if e.username then
l[e.username]=nil;
end
end
d[t]=nil;
end
local function r(e)
if o[e]then return true else return false end
end
local function v(t)
local e=0;
local a;
for i,o in pairs(l)do
if t==o then e=e+1;end
end
a=e+1;
if e>0 then return tostring(t)..tostring(a);else return tostring(t);end
end
local function m(e,t)
e.full_jid=t;
i[t]=e;
i[t]["ar_last"]={};
i[t]["nicks_changing"]={};
if e.nick then o[e.nick]=e;end
end
local function y(t)
local a=t.nick;
if t.username and t.nick then
t.send{from=e,"001",a,"Welcome in the IRC to MUC XMPP Gateway, "..a};
t.send{from=e,"002",a,"Your host is "..e.." running Prosody "..prosody.version};
t.send{from=e,"003",a,"This server was created the "..os.date(nil,prosody.start_time)}
t.send{from=e,"004",a,table.concat({e,"mod_ircd(alpha-0.8)","i","aoqv"}," ")};
t.send((":%s %s %s %s :%s"):format(e,"005",a,"CHANTYPES=# PREFIX=(qaov)~&@+","are supported by this server"));
t.send((":%s %s %s %s :%s"):format(e,"005",a,"STATUSMSG=~&@+","are supported by this server"));
t.send{from=e,"375",a,"- "..e.." Message of the day -"};
t.send{from=e,"372",a,"-"};
t.send{from=e,"372",a,"- Please be warned that this is only a partial irc implementation,"};
t.send{from=e,"372",a,"- it's made to facilitate users transiting away from irc to XMPP."};
t.send{from=e,"372",a,"-"};
t.send{from=e,"372",a,"- Prosody is _NOT_ an IRC Server and it never will."};
t.send{from=e,"372",a,"- We also would like to remind you that this plugin is provided as is,"};
t.send{from=e,"372",a,"- it's still an Alpha and it's still a work in progress, use it at your sole"};
t.send{from=e,"372",a,"- risk as there's a not so little chance something will break."};
t.send{from=a,"MODE",a,"+i"};
end
end
function n.NICK(t,a)
local a=a[1];
a=a:gsub("[^%w_]","");
if t.nick and not r(a)then
local e=t.nick;
t.nick=a;
o[e]=nil;
o[a]=t;
t.send{from=e.."!"..o[a].username,"NICK",a};
if t.rooms then
t.nicks_changing[a]={e,t.username};
for o,e in pairs(t.rooms)do e:change_nick(a);end
t.nicks_changing[a]=nil;
end
return;
elseif r(a)then
t.send{from=e,"433",a,"The nickname "..a.." is already in use"};return;
end
t.nick=a;
t.type="c2s";
o[a]=t;
if t.username then
m(t,s.join(t.username,h,"ircd"));
end
y(t);
end
function n.USER(t,a)
local a=a[1];
if not t.has_un then
local e=v(a);
l[e]=a;
t.username=e;
t.has_un=true;
if not t.full_jid then
m(t,s.join(t.username,h,"ircd"));
end
else
return t.send{from=e,"462","USER","You may not re-register."}
end
y(t);
end
function n.USERHOST(a,t)
local t=t[1];
if not t then a.send{from=e,"461","USERHOST","Not enough parameters"};return;end
if o[t]and o[t].nick and o[t].username then
a.send{from=e,"302",a.nick,t.."=+"..o[t].username};return;
else
return;
end
end
local function m(a,o,i)
local t;
local e;
e=g[a]..k[o]
t=string.rep(i.." ",e:len())
if e==""then return nil,nil end
return e,t
end
function n.JOIN(a,t)
local s=t[1];
if not s then return end
local t=b(s);
if not i[a.full_jid].ar_last[t]then i[a.full_jid].ar_last[t]={};end
local t,h=c:join_room(t,a.nick,{source=a.full_jid});
if not t then
return":"..e.." ERR :Could not join room: "..h
end
a.rooms[s]=t;
t.session=a;
if a.nicks_changing[a.nick]then
n.NAMES(a,s);
else
a.send{from=a.nick.."!"..a.username,"JOIN",s};
if t.subject then
a.send{from=e,332,a.nick,s,t.subject};
end
n.NAMES(a,s);
end
t:hook("subject-changed",function(e)
a.send{from=e.by.nick,"TOPIC",s,e.to or""}
end);
t:hook("message",function(e)
if not e.body then return end
local o,t=e.nick,e.body;
if o~=a.nick then
if t:sub(1,4)=="/me "then
t="\1ACTION "..t:sub(5).."\1"
end
local e=e.stanza.attr.type;
a.send{from=o,"PRIVMSG",e=="groupchat"and s or o,t};
end
end);
t:hook("presence",function(t)
local h;
local r;
if t.nick and not i[a.full_jid].ar_last[t.room_jid][t.nick]then i[a.full_jid].ar_last[t.room_jid][t.nick]={}end
local n=t.stanza:get_child("x","http://jabber.org/protocol/muc#user")
if n then
local n=n:get_child("item")
if n and n.attr and t.stanza.attr.type~="unavailable"then
if n.attr.affiliation and n.attr.role then
if not i[a.full_jid].ar_last[t.room_jid][t.nick]["affiliation"]and
not i[a.full_jid].ar_last[t.room_jid][t.nick]["role"]then
i[a.full_jid].ar_last[t.room_jid][t.nick]["affiliation"]=n.attr.affiliation
i[a.full_jid].ar_last[t.room_jid][t.nick]["role"]=n.attr.role
n_self_changing=o[t.nick]and o[t.nick].nicks_changing and o[t.nick].nicks_changing[t.nick]
if n_self_changing then return;end
h,r=m(n.attr.affiliation,n.attr.role,t.nick);
if h and r then a.send((":%s MODE %s +%s"):format(e,s,h.." "..r));end
else
h,r=m(i[a.full_jid].ar_last[t.room_jid][t.nick]["affiliation"],i[a.full_jid].ar_last[t.room_jid][t.nick]["role"],t.nick);
if h and r then a.send((":%s MODE %s -%s"):format(e,s,h.." "..r));end
i[a.full_jid].ar_last[t.room_jid][t.nick]["affiliation"]=n.attr.affiliation
i[a.full_jid].ar_last[t.room_jid][t.nick]["role"]=n.attr.role
n_self_changing=o[t.nick]and o[t.nick].nicks_changing and o[t.nick].nicks_changing[t.nick]
if n_self_changing then return;end
h,r=m(n.attr.affiliation,n.attr.role,t.nick);
if h and r then a.send((":%s MODE %s +%s"):format(e,s,h.." "..r));end
end
end
end
end
end,-1);
end
c:hook("groupchat/joined",function(a)
local t=a.session or i[a.opts.source];
local n="#"..a.jid:match("^(.*)@");
a:hook("occupant-joined",function(e)
if t.nicks_changing[e.nick]then
t.send{from=t.nicks_changing[e.nick][1].."!"..(t.nicks_changing[e.nick][2]or"xmpp"),"NICK",e.nick};
t.nicks_changing[e.nick]=nil;
else
t.send{from=e.nick.."!"..(o[e.nick]and o[e.nick].username or"xmpp"),"JOIN",n};
end
end);
a:hook("occupant-left",function(e)
if i[t.full_jid]then i[t.full_jid].ar_last[e.jid:match("^(.*)/")][e.nick]=nil;end
local a=
e.presence:get_child("x","http://jabber.org/protocol/muc#user")and
e.presence:get_child("x","http://jabber.org/protocol/muc#user"):get_child("status")and
e.presence:get_child("x","http://jabber.org/protocol/muc#user"):get_child("status").attr.code;
if a=="303"then
local a=
e.presence:get_child("x","http://jabber.org/protocol/muc#user")and
e.presence:get_child("x","http://jabber.org/protocol/muc#user"):get_child("item")and
e.presence:get_child("x","http://jabber.org/protocol/muc#user"):get_child("item").attr.nick;
t.nicks_changing[a]={e.nick,(o[e.nick]and o[e.nick].username or"xmpp")};return;
end
for o,a in pairs(t.nicks_changing)do
if a[1]==e.nick then return;end
end
t.send{from=e.nick.."!"..(o[e.nick]and o[e.nick].username or"xmpp"),"PART",n};
end);
end);
function n.NAMES(a,o)
local i={};
if type(o)=="table"then o=o[1]end
local t=a.rooms[o];
local n={
owner="~",
administrator="&",
moderator="@",
member="+"
}
if not t then return end
for t,e in pairs(t.occupants)do
if e.affiliation=="owner"and e.role=="moderator"then
t=n[e.affiliation]..t;
elseif e.affiliation=="administrator"and e.role=="moderator"then
t=n[e.affiliation]..t;
elseif e.affiliation=="member"and e.role=="moderator"then
t=n[e.role]..t;
elseif e.affiliation=="member"and e.role=="partecipant"then
t=n[e.affiliation]..t;
elseif e.affiliation=="none"and e.role=="moderator"then
t=n[e.role]..t;
end
table.insert(i,t);
end
i=table.concat(i," ");
a.send((":%s 353 %s = %s :%s"):format(e,a.nick,o,i));
a.send((":%s 366 %s %s :End of /NAMES list."):format(e,a.nick,o));
a.send(":"..e.." 353 "..a.nick.." = "..o.." :"..i);
end
function n.PART(a,t)
local t,n=unpack(t);
local o=t and w(t:match("^#(%w+)"))or nil;
if not o then return end
t=t:match("^([%S]*)");
a.rooms[t]:leave(n);
i[a.full_jid].ar_last[o.."@"..e]=nil;
a.send{from=a.nick.."!"..a.username,"PART",t};
end
function n.PRIVMSG(a,e)
local t,e=unpack(e);
if e and#e>0 then
if e:sub(1,8)=="\1ACTION "then
e="/me "..e:sub(9,-2)
end
e=u(e);
if t:sub(1,1)=="#"then
if a.rooms[t]then
module:log("debug","%s sending PRIVMSG \"%s\" to %s",a.nick,e,t);
a.rooms[t]:send_message(e);
end
else
local t=t;
module:log("debug","PM to %s",t);
for o,a in pairs(a.rooms)do
module:log("debug","looking for %s in %s",t,o);
if a.occupants[t]then
module:log("debug","found %s in %s",t,o);
local o=a.occupants[t];
local e=p.message({type="chat",to=o.jid},e);
module:log("debug","sending PM to %s: %s",t,tostring(e));
a:send(e)
break
end
end
end
end
end
function n.PING(a,t)
a.send{from=e,"PONG",t[1]};
end
function n.TOPIC(a,e)
if not e then return end
local e,t=e[1],e[2];
e=u(e);
t=u(t);
if not e then return end
local e=a.rooms[e];
if t then e:set_subject(t);end
end
function n.WHO(t,a)
local a=a[1];
if t.rooms[a]then
local o=t.rooms[a]
for o in pairs(o.occupants)do
t.send{from=e,352,t.nick,a,o,o,e,o,"H","0 "..o}
end
t.send{from=e,315,t.nick,a,"End of /WHO list"};
end
end
function n.MODE(e,e)
end
function n.QUIT(e,t)
e.send{"ERROR","Closing Link: "..e.nick};
for a,e in pairs(e.rooms)do
e:leave(t[1]);
end
i[e.full_jid]=nil;
o[e.nick]=nil;
l[e.username]=nil;
d[e.conn]=nil;
e:close();
end
function n.RAW(e,e)
end
module:provides("net",{
name="ircd";
listener=f;
default_port=7e3;
});
