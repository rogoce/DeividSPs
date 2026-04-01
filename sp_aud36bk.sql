-- Procedure para auditoria interna - Archivo de Reclamo - Leyri Moreno
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud36bk;		
create procedure sp_aud36bk(a_periodo char(7))
returning char(7);
		  		  
define _no_poliza    char(10);
define _cnt,_holgura,_ano,_mes		     integer;
define a_sucursal 	 char(350);
define _cod_sucursal char(3);
define _tipo         char(1);
define _fecha_act,_vig_ini,_fecha_result,_fec_inivig,_fecha,_fecha2  date;
define _rrc_100,_prima_susc_neta dec(16,2);
define _periodo char(7);
define _mes_char char(2);
define _mes_periodo smallint;


--let _ano = year(a_fecha_noti);
{let _fec_inivig = '07/01/2000';

let _fecha = MDY(month(_fec_inivig), day(_fec_inivig), _ano);
let _ano = _ano - 1;
let _fecha2 = MDY(month(_fec_inivig), day(_fec_inivig), _ano);

let _mes_periodo = 9;
let _fecha = mdy(_mes_periodo,1,'2025');
let _fecha =  _fecha - 2 units month;}

let _ano = a_periodo[1,4];
let _mes = a_periodo[6,7];
if _mes = 1 then
	let _ano = _ano - 1;
	let _periodo = _ano || "-12";
else
    if _mes < 10 then
		let _periodo = _ano || "-0" || _mes - 1;
	else
		let _periodo = _ano || "-" || _mes - 1;
	end if
end if


return _periodo;

{if a_mes < 10 then
	let _mes_char = "0" || a_mes;
else
	let _mes_char = a_mes;
end if
let _periodo = a_ano || "-" || _mes_char;
return _periodo;

let _fecha_act = current;

let _vig_ini = a_fecha_noti;
let _holgura = 1;
let _fecha_result = _vig_ini + _holgura units year;

let _fec_inivig = '14/10/2023';
let _prima_susc_neta = 75.12;

let _rrc_100 = (a_fecha_noti - a_fecha_sini) / (a_fecha_noti - _fec_inivig) * _prima_susc_neta;

--return _vig_ini,_fecha_result,_rrc_100;

{let _fecha_menos_ini = MDY(month(_fecha_fin_aa), 1, year(_fecha_fin_aa));			--01/12/2019
let _fecha_menos_ini = _fecha_menos_ini - 14 units month;							--01/10/2018

let _fecha_menos_fin = MDY(month(_fecha_fin_aa), 1, year(_fecha_fin_aa));			--01/12/2019
let _fecha_menos_fin = _fecha_menos_fin - 3 units month;							--01/09/2019
let _mes = month(_fecha_menos_fin);

let _dia = day(_fecha_fin_aa);
if _mes = 2 then
	let _dia = 28;
	let _fecha_menos_fin = MDY(month(_fecha_menos_fin), _dia, year(_fecha_menos_fin));
else
    if _mes in(4,6,9,11) And day(_fecha_fin_aa) = 31 then
		let _dia = 30;
	end if
	let _fecha_menos_fin = MDY(month(_fecha_menos_fin), _dia, year(_fecha_menos_fin));
end if}


{let a_sucursal = '001';
foreach
	select codigo_agencia
	  into _cod_sucursal 
	  from insagen   
	 where sucursal_promotoria <> '001' 
	
	let a_sucursal = trim(a_sucursal) || ',' || trim(_cod_sucursal);
end foreach 

let a_sucursal = trim(a_sucursal) || ';';  
let _tipo = sp_sis04(a_sucursal); -- Separa los valores del String 

return 0;
--return days(a_fecha_noti);}


end procedure

