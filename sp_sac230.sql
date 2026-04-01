-- Procedure que Actualiza los saldos de las cuentas del mayor

-- Creado    : 04/09/2013 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
-- drop procedure sp_sac230;

create procedure sp_sac230(
a_compania	char(3), 
a_notrx		integer 
) returning integer,
            char(100);

define _cuenta		char(25);
define w2_ccosto	char(3);
define _fecha		date;
define _concepto	char(3);
define _estatus		char(1);
define pant_ano 	integer;
define pant_mes 	integer;
define w_status1    char(1);

define pdebitos		dec(16,2);
define pcreditos	dec(16,2);
define pdebitos2	dec(16,2);
define pcreditos2	dec(16,2);
define psaldo2		dec(16,2);

define wcta_nivel	char(1);
define ls_auxiliar	char(5);
define indice		smallint;
define nivel1		smallint;
define pos2			smallint;
define work_cta		char(25);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Solo para SAC NIIF

-- Se usan las tablas de sac009
-- cglresumen, cglresumen1, cglsaldodet, cglsaldoaux1				 
-- que son las de movimientos

-- las tablas operativas se usan de sac

if a_compania <> "010" then
	return 0, "Actualizacion Exitosa";
end if

-- Seleccion de la fecha y el concepto para determinar
-- el periodo contable

foreach
 select res_fechatrx,
        res_tipcomp, 
   into _fecha,
        _concepto,
   from sac009:cglresumen
  where res_notrx = a_notrx
--  group by res_fechatrx, res_tipcomp
	exit foreach;
end foreach

select con_status 
  into w_status1  
  from cglconcepto
 where con_codigo = _concepto;

 if w_status1 is null then
	return 1, "No Existe Concepto " || _concepto;
 end if

select per_ano, 
       per_mes
  into pant_ano, 
       pant_mes
  from cglperiodo
 where _fecha between per_inicio and per_final
   and per_status1 = w_status1;

if wper_ano is null then
	return 1, "No Existe Periodo Para la Fecha " || _fecha;
end if

foreach
 select res_ccosto,
        res_cuenta, 
        sum(res_debito), 
        sum(res_credito)
   into w2_ccosto,
        _cuenta,
        pdebitos,
        pcreditos
   from sac009:cglresumen
  where res_notrx = a_notrx
  group by res_ccosto, res_cuenta

	if pdebitos is null then
		let pdebitos = 0;
	end if

	if pcreditos is null then
    	let pcreditos = 0;
	end if

	let pcreditos = pcreditos * -1;

	select cta_nivel
	  into wcta_nivel
	  from cglcuentas
     where cta_cuenta = _cuenta;

	if wcta_nivel is null then
		continue foreach;
	end if

	let nivel1 = wcta_nivel;

	for indice = nivel1 to 1 step -1

		select est_posfinal 
          into pos2
          from cglestructura
         where est_nivel = indice;

		let work_cta = substring(_cuenta from 1 for pos2);

		select sldet_debtop,
		       sldet_cretop,
		       sldet_saldop
          into pdebitos2,
               pcreditos2,
               psaldo2 
          from sac009:cglsaldodet
         where sldet_tipo    = "01"
           and sldet_cuenta  = work_cta
           and sldet_ano     = pant_ano
           and sldet_periodo = pant_mes
           and sldet_ccosto  = w2_ccosto;

		let pdebitos2  = pdebitos2  + pdebitos ;
		let pcreditos2 = pcreditos2 + pcreditos ;
		let psaldo2    = psaldo2    + pdebitos + pcreditos ;

		{
       update sac009:cglsaldodet
          set sldet_debtop  = pdebitos2,
              sldet_cretop  = pcreditos2,
              sldet_saldop  = psaldo2
        where sldet_tipo    = "01"
          and sldet_cuenta  = work_cta
          and sldet_ano     = pant_ano
          and sldet_periodo = pant_mes
          and sldet_ccosto  = w2_ccosto;
		}

	end for

end foreach

-- Movimientos de los Auxiliares

foreach
 select res_cuenta, 
        res1_auxiliar,
        sum(res1_debito), 
        sum(res1_credito)
   into _cuenta,
   		ls_auxiliar,
   		pdebitos,
   		pcreditos
   from sac009:cglresumen, sac009:cglresumen1
  where res_noregistro = res1_noregistro
    and res_notrx      = a_notrx
  group by res_cuenta, res1_auxiliar

	if pdebitos is null then
		let pdebitos = 0;
	end if

	if pcreditos is null then
    	let pcreditos = 0;
	end if

	let pcreditos = pcreditos * -1;

	select sld1_debitos,
	       sld1_creditos,
	       sld1_saldo
	  into pdebitos2,
	       pcreditos2,
	       psaldo2 
	  from sac009:cglsaldoaux1
	 where sld1_tipo    = "01"
	   and sld1_cuenta  = _cuenta
	   and sld1_tercero = ls_auxiliar
	   and sld1_ano     = pant_ano
	   and sld1_periodo = pant_mes;

    let pdebitos2  = pdebitos2  + pdebitos;
    let pcreditos2 = pcreditos2 + pcreditos;
    let psaldo2    = psaldo2    + pdebitos + pcreditos;

	{
   update sac009:cglsaldoaux1
      set sld1_debitos  = pdebitos2,
          sld1_creditos = pcreditos2,
          sld1_saldo    = psaldo2
    where sld1_tipo     = "01"
      and sld1_cuenta   = _cuenta
      and sld1_tercero  = ls_auxiliar
      and sld1_ano      = pant_ano
      and sld1_periodo  = pant_mes;
	}

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure
