-- Procedimiento valida periodo cerrado de comprobante 
-- Creado    : 18/01/2011 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac197;
create procedure "informix".sp_sac197(a_fecha date, a_concepto char(3)) 
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
--set debug file to "sp_sac197.trc";
--trace on;

LET ls_mes  = "00" ;
let ls_anio = Year(a_fecha);
let li_mes  = Month(a_fecha);

li_existe = 0;
					
SELECT count(*)
  INTO li_existe
  FROM cglparam
 WHERE cglparam.par_anofiscal = ls_anio
   AND cglparam.par_mesfiscal = li_mes; 	

if li_existe = 0 or isnull(li_existe) then 
	return 1,'No es Permitido actualizar el comprobante. Fecha no corresponde al Periodo Fiscal Vigente.',a_fecha;
end if	

let ls_concepto = trim(a_concepto);

SELECT cglparam.par_mesfiscal,par_anofiscal
  INTO ls_mesfiscal, ls_anofiscal  
  FROM cglparam ;  
-- WHERE cglparam.par_anofiscal = ls_anio;
let li_anofiscal = ls_anofiscal;
let li_mesfiscal = ls_mesfiscal;
--let ld_fecha_correcta  = MDY(12, 31,li_anofiscal);
--let ld_fecha_correcta  = MDY(li_mesfiscal, 31,li_anofiscal);
let ls_periodo = ls_anofiscal||'-'||ls_mesfiscal;
let ld_fecha_correcta  = sp_sis36(ls_periodo);
 if ls_anio is null then 
    let ls_anio = '0000';
end if

 if ls_mes is null  then 
    let ls_mes = '00';
end if

if li_mes < 10 then 
	let ls_mes[2,2] = li_mes ;
else
	let ls_mes = li_mes ;
end if

select  count(*)
 into   li_existe
 FROM   cglperiodo  
WHERE   cglperiodo.per_ano = ls_anio
  and   cglperiodo.per_mes = ls_mes;
  
if li_existe is null or li_existe = 0 then
	return 1,'No existe Periodo Registrado',ld_fecha_correcta;
end if
 
select  cglperiodo.per_status 
 into   ls_estatus
 FROM   cglperiodo  
WHERE   cglperiodo.per_ano = ls_anio
  and   cglperiodo.per_mes = ls_mes;

if a_fecha > ld_fecha_correcta  then   
   if ls_mesfiscal = "13" or ls_mesfiscal = "14"  then
   else
	If ls_estatus = "C" Then
		Return 1,"Periodo Cerrado",ld_fecha_correcta;
	else
	   let ld_fecha_correcta = a_fecha;    -- se adiciona para permitir registrar despues del cierre	
	   Return 0,"Validacion Correcta",ld_fecha_correcta;
	End If
   end if   
else
	if ls_concepto = "020" then   
		if ls_mesfiscal <> "13" then 
		   Return 1,"Concepto de Comprobante Incorrecto.",ld_fecha_correcta;
		end if
	end if
	if ls_concepto = "021" then   
		if ls_mesfiscal <> "14" then 
		   Return 1,"Concepto de Comprobante Incorrecto.",ld_fecha_correcta;
		end if
	end if
end if

if ls_mesfiscal = "13" then 
	if ls_concepto = "020" then
		if a_fecha > ld_fecha_correcta then	   
		   return 2,"Debe colocar la Fecha a 31 de Diciembre de "||trim(ls_anofiscal),ld_fecha_correcta;
	   end if
	else		
		if ls_anio > ls_anofiscal then
			Return 0,"Validacion Correcta",ld_fecha_correcta;
		 else
		 	select trim(con_descrip)||" - "||trim(con_codigo)
			  into ls_descrip
		 	  from cglconcepto
			 where con_codigo = "020";

		 	Return 1,"Concepto de Comprobante Equivocado.Favor colocar "||ls_descrip,ld_fecha_correcta;
		end if
	end if
end if

if ls_mesfiscal = "14" then 
	if ls_concepto = "021" then
		if a_fecha > ld_fecha_correcta then	   
		   return 2,"Debe colocar la Fecha a 31 de Diciembre de "||trim(ls_anofiscal),ld_fecha_correcta;
	   end if
	else
		if ls_anio > ls_anofiscal then
			Return 0,"Validacion Correcta",ld_fecha_correcta;
		 else
		 	select trim(con_descrip)||" - "||trim(con_codigo)
			  into ls_descrip
		 	  from cglconcepto
			 where con_codigo = "021";

		 	Return 1,"Concepto de Comprobante Equivocado.Favor colocar "||ls_descrip,ld_fecha_correcta;
		end if
	end if
end if

Return 0,"Validacion Correcta",ld_fecha_correcta;

end procedure
