-- Procedimiento valida periodo cerrado de comprobante -- PARA LA ACTUALIZACION
-- Creado    : 18/01/2011 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac204;
create procedure "informix".sp_sac204(a_fecha date, a_concepto char(3),a_acme char(1)) 
returning integer,char(255),date;

define li_existe		integer;
define ls_anio  		char(4);
define li_mes   		integer;
define li_anio   		integer;
define ls_mes   		char(2);
define ls_periodo  		char(7);
define ls_anofiscal     char(4);
define ls_mesfiscal   	char(2);
define li_mesfiscal		integer;
define ls_concepto      char(3);
define ls_estatus       char(1);
define ld_fecha_correcta   date;
define li_anofiscal     integer;
define ls_descrip       char(50);

SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT;
--0 Correcto 1 Error
--set debug file to "sp_sac204.trc";
--trace on;

LET ls_mes  = "00" ;
let ls_anio = Year(a_fecha);
let li_mes  = Month(a_fecha);

let li_existe = 0 ;
let ld_fecha_correcta = a_fecha;
					
SELECT count(*)
  INTO li_existe
  FROM cglparam
 WHERE cglparam.par_anofiscal = ls_anio
   AND cglparam.par_mesfiscal = li_mes; 	
 
if li_existe is null or li_existe = 0 then
	return 0,'No es Permitido actualizar el comprobante. Fecha no corresponde al Periodo Fiscal Vigente.',ld_fecha_correcta;
end if	

Return 0,"Validacion Correcta",ld_fecha_correcta;

end procedure
