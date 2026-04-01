-- Procedure que Crea las Cuentas del Catalogo de Cuentas sin el guion

-- Creado    : 10/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac03;

create procedure sp_sac03(_cuenta_con char(25)) 
returning char(25);

define _cuenta_sin	char(25);

define _01			char(1);
define _02			char(1);
define _03			char(1);
define _04			char(1);
define _05			char(1);
define _06			char(1);
define _07			char(1);
define _08			char(1);
define _09			char(1);
define _10			char(1);
define _11			char(1);
define _12			char(1);
define _13			char(1);
define _14			char(1);
define _15			char(1);
define _16			char(1);
define _17			char(1);
define _18			char(1);

let _01 = _cuenta_con[1];
let _02 = _cuenta_con[2];
let _03 = _cuenta_con[3];
let _04 = _cuenta_con[4];
let _05 = _cuenta_con[5];
let _06 = _cuenta_con[6];
let _07 = _cuenta_con[7];
let _08 = _cuenta_con[8];
let _09 = _cuenta_con[9];
let _10 = _cuenta_con[10];
let _11 = _cuenta_con[11];
let _12 = _cuenta_con[12];
let _13 = _cuenta_con[13];
let _14 = _cuenta_con[14];
let _15 = _cuenta_con[15];
let _16 = _cuenta_con[16];
let _17 = _cuenta_con[17];
let _18 = _cuenta_con[18];

let _cuenta_sin = "";

if _01 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _01;
end if

if _02 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _02;
end if

if _03 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _03;
end if

if _04 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _04;
end if

if _05 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _05;
end if

if _06 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _06;
end if

if _07 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _07;
end if

if _08 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _08;
end if

if _09 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _09;
end if

if _10 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _10;
end if

if _11 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _11;
end if

if _12 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _12;
end if

if _13 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _13;
end if

if _14 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _14;
end if

if _15 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _15;
end if

if _16 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _16;
end if

if _17 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _17;
end if

if _18 <> "-" then
	let _cuenta_sin = trim(_cuenta_sin) || _18;
end if

return _cuenta_sin;

end procedure