-- Procedimiento que crea tabla temporal con el codigo principa y sus unificados
-- creado: 23/09/2025 - Armando Moreno M.

DROP PROCEDURE sp_che168a;
CREATE PROCEDURE sp_che168a(a_agente CHAR(8))
                  RETURNING SMALLINT,char(8);  

DEFINE _cod_agente        CHAR(8);
DEFINE _error		      INTEGER;
DEFINE _error_mess 	      CHAR(50);
define _unificar          smallint;
define _valor_char        char(1);

let _cod_agente = "";
let _unificar = 0;

set isolation to dirty read;
--set debug file to "sp_che168.trc";
--trace on;
let _error = 0;
let _error_mess = '';
let _cod_agente = a_agente;
begin
on exception set _error
	return _error,_error_mess;  
end exception

IF _cod_agente in('02882','02758','00026') then
	let _cod_agente = "00026";
	let _valor_char = sp_sis04('00026,02882,02758;');
end if

IF _cod_agente in('02056','01058') then
	let _cod_agente = "01058";
	let _valor_char = sp_sis04('02056,01058;');
end if

IF _cod_agente in('02910','01040') then
	let _cod_agente = "01040";
	let _valor_char = sp_sis04('02910,01040;');
end if
IF _cod_agente in('02950','03102') then
	let _cod_agente = "03102";
	let _valor_char = sp_sis04('02950,03102;');			
end if
 
IF _cod_agente in('02468','02698','02699','02989') then
	let _cod_agente = "02468";
	let _valor_char = sp_sis04('02468,02698,02699,02989;');
end if
IF _cod_agente in('02642','02731','02732','02762') then
	let _cod_agente = "02642";
	let _valor_char = sp_sis04('02642,02731,02732,02762;');			
end if
IF _cod_agente in('02351','01988') then			--Unificar Genesis Asesores de seguros(Panama) con Genesis Asesores de seguros, s.a.
	let _cod_agente = "01988";
	let _valor_char = sp_sis04('01988,02351,01988;');
end if
if _cod_agente in('02111','02569') then 		--Unificar Javier Cardenas(Panama) con Javier Cardenas.
	let _cod_agente = "02111";
	let _valor_char = sp_sis04('02111,02569;');
end if

if _cod_agente in('01459','02547') then 		--Unificar Magda Crespo codigo anterior con el nuevo codigo de ella.
	let _cod_agente = "02547";
	let _valor_char = sp_sis04('02547,01459;');
end if
if _cod_agente in('02243','00473') then 		--Unificar Inversiones y Seguros Panamericanos, S. A. (CH) a Inversiones y Seguros Panamericanos, S. A.
	let _cod_agente = "00473";
	let _valor_char = sp_sis04('02243,00473;');
end if
if _cod_agente in('02352','03035') then
	let _cod_agente = "03035";
	let _valor_char = sp_sis04('02352,03035;');
end if
if _cod_agente in('01321','02915','03170','03169') then
	let _cod_agente = "01321";
	let _valor_char = sp_sis04('01321,02915,03170,03169;');
end if
if _cod_agente in('00037','02897','00221','00026') then
	let _cod_agente = "00037";
	let _valor_char = sp_sis04('00037,02897,00221,00026;');
end if

if _cod_agente in('01555','01481') then 		--Unificar Jose Caballero a Marta Caballero
	let _cod_agente = "01555";
	let _valor_char = sp_sis04('01555,01481;');
end if
if _cod_agente in('02825','02531','02302','02354','02319','02829','02830','02831') then --Unificar LIZSENELL GIONELLA BERNAL RAMIREZ, correo 24/03/17 Alicia. Se quita unificacion correo Analisa 19/02/2018
	let _cod_agente = "02825";
	let _valor_char = sp_sis04('02825,02531,02302,02354,02319,02829,02830,02831;');
end if
if _cod_agente in('01480','01479') then --Unificar Ricardo Caballero, a Patricia Caballero
	let _cod_agente = "01479";
	let _valor_char = sp_sis04('01479,01480;');
end if

if _cod_agente in('02532','02129','02130','02050','01001','01000','01002','01609','01005') then --Unificar Felix Abadia
	let _cod_agente = "01001";
	let _valor_char = sp_sis04('02532,02129,02130,02050,01001,01000,01002,01609,01005;');
end if
if _cod_agente in('00816','00288','02161','02379') then --Unificar Osacar andrade cubilla, Oscar Andrade Cubilla Panamá y Oscar xavier Andrade a ANDRADE 00816, correo Analisa 29/01/2018
	let _cod_agente = "00816";
	let _valor_char = sp_sis04('00816,00288,02161,02379;');
end if
let _unificar = 0;	 --Unificar FF Seguros	:25/04/2013 Leticia
SELECT count(*)
  INTO _unificar
  FROM agtagent 
 WHERE cod_agente      = _cod_agente
   AND agente_agrupado = "01068";
   
if _unificar <> 0 then
   let _cod_agente = "01068";
end if

let _unificar = 0;	 --Unificar SOMOS SEGUROS	:08/05/2017 Correo de Analiza.
SELECT count(*)
  INTO _unificar
  FROM agtagent 
 WHERE cod_agente      = _cod_agente
   AND agente_agrupado = "02420";
if _unificar <> 0 then
   let _cod_agente = "02420";
end if		   

if _cod_agente in ('01435',"00636","00732","00731","02405",'02785') then
  let _cod_agente = "01435";
  let _valor_char = sp_sis04('01435,00636,00732,00731,02405,02785;');
end if

if _cod_agente in ('01048',"02599","01837","01569","01838","00623","01836","01575","01835","02201","02252","02448","02253",'03010') then  --- falta 02201 LATTY
  let _cod_agente = "01048";
  let _valor_char = sp_sis04('01048,02599,01837,01569,01838,00623,01836,01575,01835,02201,02252,02448,02253,03010;');
end if	   

if _cod_agente in ('01266',"02155","00095","00130","00235") then	   --Cambio segun sol. 29/05/2014 por Leticia Escobar.
  let _cod_agente = "01266";
  let _valor_char = sp_sis04('01266,02155,00095,00130,00235;');
end if

if _cod_agente IN ('00218','02917','02528','02524','02523','02525','02527','02526','02353',"02082","02360","02376","02293","02377","02378","02375","00133","01746","01749","01852","02004","02075","02124") then  
	let _cod_agente = "00218";
	let _valor_char = sp_sis04('00218,02917,02528,02524,02523,02525,02527,02526,02353,02082,02360,02376,02293,02377,02378,02375,00133,01746,01749,01852,02004,02075,02124;');
end if

if _cod_agente in('00395',"01880") then
	let _cod_agente = "00395";
	let _valor_char = sp_sis04('00395,01880;');
end if	

if _cod_agente in('00946',"00239") then
	let _cod_agente = "00946";
	let _valor_char = sp_sis04('00946,00239;');
end if

if _cod_agente in("01853","01814",'00270') then
	let _cod_agente = "00270";
	let _valor_char = sp_sis04('01853,01814,00270;');
end if

if _cod_agente in("02015",'00125') then
	let _cod_agente = "00125";
	let _valor_char = sp_sis04('00125,02015;');
end if

if _cod_agente in("02154","02618",'02656','02904','00035') then
	let _cod_agente = "00035";
	let _valor_char = sp_sis04('02454,02618,02656,02904,00035;');
end if

if _cod_agente in('00166',"01745","01743","01744","01751","01851") then
	let _cod_agente = "00166";
	let _valor_char = sp_sis04('00166,01745,01743,01744,01751,01851;');
end if

if _cod_agente in("02081",'00474') then
	let _cod_agente = "00474";
	let _valor_char = sp_sis04('02081,00474;');
end if

if _cod_agente in("01990",'01009') then
	let _cod_agente = "01009";
	let _valor_char = sp_sis04('01990,01009;');
end if

if _cod_agente in("02103",'01670') then
	let _cod_agente = "01670";
	let _valor_char = sp_sis04('02103,01670;');
end if

if _cod_agente in("02196",'01898') then
	let _cod_agente = "01898";
	let _valor_char = sp_sis04('01898,02196;');
end if

if _cod_agente in("00197",'00291') then
	let _cod_agente = "00291";
	let _valor_char = sp_sis04('00197,00291;');
end if

if _cod_agente in('00011',"01904","00138","01867","00965") then
	let _cod_agente = "00011";
	let _valor_char = sp_sis04('00011,01904,00138,01867,00965;');
end if

if _cod_agente in("01948",'02208') then
	let _cod_agente = "02208";
	let _valor_char = sp_sis04('02208,01948;');
end if

if _cod_agente in("02102",'00817') then
	let _cod_agente = "00817";
	let _valor_char = sp_sis04('00817,02102;');
end if

if _cod_agente in("00517",'01440') then
	let _cod_agente = "01440";
	let _valor_char = sp_sis04('00517,01440;');
end if

if _cod_agente in("00525",'00779') then
	let _cod_agente = "00779";
	let _valor_char = sp_sis04('00779,00525;');
end if

if _cod_agente in("00076","00937",'02119') then
	let _cod_agente = "02119";
	let _valor_char = sp_sis04('00076,00937,02119;');
end if

if _cod_agente in("02337",'00845') then
	let _cod_agente = "00845";
	let _valor_char = sp_sis04('00845,02337;');
end if

if _cod_agente in("01916",'00793') then
	let _cod_agente = "00793";
	let _valor_char = sp_sis04('01916,00793;');
end if

if _cod_agente in("00104","02037",'00119') then
	let _cod_agente = "00119";
	let _valor_char = sp_sis04('00104,02037,00119;');
end if
if _cod_agente in("01779",'02229') then
	let _cod_agente = "02229";
	let _valor_char = sp_sis04('01779,02229;');
end if

if _cod_agente in("01504",'02424') then
	let _cod_agente = "02424";
	let _valor_char = sp_sis04('01504,02424;');
end if

if _cod_agente in("01711",'02134') then
	let _cod_agente = "02134";
	let _valor_char = sp_sis04('02134,01711;');
end if

if _cod_agente in("02340","02086",'01061') then
	let _cod_agente = "01061";
	let _valor_char = sp_sis04('02340,02086,01061;');
end if

if _cod_agente in("00817",'02230') then
	let _cod_agente = "02230";
	let _valor_char = sp_sis04('02230,00817;');
end if

if _cod_agente in('02790','02798','02799','01992','01204') then
	let _cod_agente = "01204";
	let _valor_char = sp_sis04('02790,02798,02799,01992,01204;');
end if

if _cod_agente in("00202",'01753') then 
	let _cod_agente = "01753";
	let _valor_char = sp_sis04('00202,01753;');
end if	

if _cod_agente in("01823",'01438') then 
	let _cod_agente = "01438";
	let _valor_char = sp_sis04('01823,01438;');
end if	

if _cod_agente in("01046","00741",'02122') then 
	let _cod_agente = "02122";
	let _valor_char = sp_sis04('01046,00741,02122;');
end if	

if _cod_agente in("02341",'01210') then 
	let _cod_agente = "01210";
	let _valor_char = sp_sis04('02341,01210;');
end if	

if _cod_agente in("02029",'01264') then 
	let _cod_agente = "01264";
	let _valor_char = sp_sis04('02029,01264;');
end if	

if _cod_agente in("02431","02429",'02229') then 
	let _cod_agente = "02229";
	let _valor_char = sp_sis04('02431,02429,02229;');
end if

if _cod_agente in("02634",'00996') then 
	let _cod_agente = "00996";
	let _valor_char = sp_sis04('02634,00996;');
end if	

if _cod_agente in("02430","02370",'02372','02947','02973') then 
	let _cod_agente = "02973";
	let _valor_char = sp_sis04('02430,02370,02372,02947,02973;');
end if	

if _cod_agente in("01245","01249",'01244') then 
	let _cod_agente = "01244";
	let _valor_char = sp_sis04('01244,01245,01249;');
end if	

if _cod_agente in("02474","02451",'02473') then
	let _cod_agente = "02473";
	let _valor_char = sp_sis04('0274,02451,02473;');
end if

if _cod_agente in("02471",'02407') then 
	let _cod_agente = "02407";
	let _valor_char = sp_sis04('02471,02407;');
end if	

if _cod_agente in("02204",'02547') then 
	let _cod_agente = "02547";
	let _valor_char = sp_sis04('02204,02547;');
end if	

if _cod_agente in("02514",'01999') then 
	let _cod_agente = "01999";
	let _valor_char = sp_sis04('02514,01999;');
end if	

if _cod_agente in('02427',"02570",'00370','00874') then 
	let _cod_agente = "02427";
	let _valor_char = sp_sis04('02427,02570,00370,00874;');
end if	

if _cod_agente in("00549","01866",'01714') then
	let _cod_agente = "01714";
	let _valor_char = sp_sis04('00549,01866,01714;');
end if	

if _cod_agente in("02118",'00120') then 
	let _cod_agente = "00120";
	let _valor_char = sp_sis04('02118,00120;');
end if	

if _cod_agente in("01806",'01096') then 
	let _cod_agente = "01096";
	let _valor_char = sp_sis04('01806,01096;');
end if	

if _cod_agente in("02452",'02334') then 
	let _cod_agente = "02334";
	let _valor_char = sp_sis04('02452,02334;');
end if

if _cod_agente in('02667','01315','01834','03182','02888','02883','02848','02956','02393','02349') then
	let _cod_agente = "02667";
	let _valor_char = sp_sis04('02667,01315,01834,03182,02888,02883,02848,02956,02393,02349;');
end if

if _cod_agente in('02757','02863','02864','02867') then
	let _cod_agente = '02757';
	let _valor_char = sp_sis04('02757,02863,02864,02867;');
end if

if _cod_agente in("02901",'01589') then 
	let _cod_agente = "01589";
	let _valor_char = sp_sis04('02901,01589;');
end if
end
return 0,_cod_agente;

END PROCEDURE