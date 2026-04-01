-- Procedure que Obtiene los Datos para Incluir 
-- Una Poliza que se Decidio Renovar 
--
-- Creado    : 12/12/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 12/12/2001 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_prod_ren_si_renovar - DEIVID, S.A.

drop procedure sp_pro28a;
create procedure sp_pro28a(
a_usuario char(8), 
a_poliza  char(10)
) returning char(10), 
            char(20), 
            char(10), 
            smallint, 
            smallint, 
            char(3), 
            date, 
            date, 
            decimal(16,2), 
            smallint, 
            decimal(16,2), 
            decimal(16,2),
            char(5);

begin

define v_documento  	char(20);
define v_factura    	char(10);
define v_renovar    	smallint;
define v_cod_renovar 	smallint;
define v_cod_no_renovar char(3);
define v_vigencia_inic  date;
define v_vigencia_fin   date;
define v_tipo       	char(3);
define v_saldo      	decimal(16,2);
define v_cant       	smallint;
define v_cantidad   	smallint;
define v_incurrido  	decimal(16,2);
define v_pagos      	decimal(16,2);
define v_tot_pagos  	decimal(16,2);
define _perd_total  	smallint;
define _todas_perdida  	smallint;
define _porc_partic  	decimal(5,2);
define _cod_agente		char(5);

set isolation to dirty read;

let v_pagos          = 0;
let v_incurrido      = 0;
let v_cantidad       = 0;
let v_saldo          = 0;
let v_renovar        = 0;
let v_cod_renovar    = 0;
let v_cod_no_renovar = "";

if a_poliza = '1910942' then
	set debug file to "sp_pro28a.trc";
	trace on;
end if

foreach
 select no_documento, 
		no_factura,
        renovada, 
        vigencia_inic, 
        vigencia_final, 
        saldo
   into v_documento, 
 	    v_factura, 
 	    v_renovar, 
        v_vigencia_inic, 
        v_vigencia_fin, 
        v_saldo
   from emipomae
  where no_poliza       = a_poliza
    and renovada        = 0
    and incobrable      = 0
    and abierta         = 0
    and actualizado     = 1
    and estatus_poliza  IN (1,3)

	-- Excluir la poliza si todas las unidades son perdida

    let _todas_perdida = 1;
	foreach
	 select perd_total 
	   into _perd_total
	   from emipouni
	  where no_poliza = a_poliza
		if _perd_total = 0 then
			let _todas_perdida = 0;
			exit foreach;
		end if
	end foreach

	if _todas_perdida = 1 then
		continue foreach;
	end if

	-- No Incluir la Poliza si fue Seleccionada por Otro Usuario

	let v_cant = 0;
	select count(*) 
      into v_cant 
      from emirepol
     where no_poliza  =  a_poliza
       and user_added <> a_usuario;

	if v_cant > 0 Then
		continue foreach;
	end If

    delete from emirepol
     where no_poliza   = a_poliza;

	let v_cantidad = 0;
    select count(*) 
      into v_cantidad 
      from recrcmae
     where recrcmae.no_poliza   = a_poliza
       and recrcmae.actualizado = 1;

	if v_cantidad is null then
		let v_cantidad = 0;
	end if

	-- Pagos, Salvamentos, Recuperos y Deducibles

   let v_tot_pagos = 0;
   foreach
	select x.cod_tipotran 
      into v_tipo
      from rectitra x
     where x.tipo_transaccion  IN (4,5,6,7)

		select sum(x.monto) 
          into v_pagos
          from rectrmae x, recrcmae y
         where y.no_poliza     = a_poliza
           and y.actualizado   = 1
           and x.no_reclamo    = y.no_reclamo
           and x.actualizado   = 1
           and x.cod_tipotran  = v_tipo;

		if v_pagos is null then
	        let v_pagos = 0;
	    end if

		let v_tot_pagos = v_tot_pagos + v_pagos;

   end foreach

	-- Variacion de Reserva

	select sum(x.variacion) 
	  into v_incurrido
      from rectrmae x, recrcmae y
     where y.no_poliza   = a_poliza
       and y.actualizado = 1
       and x.no_reclamo  = y.no_reclamo
       and x.actualizado = 1;

	if v_incurrido is null then
		let v_incurrido = 0;
	end if

	-- Incurrido

	let v_incurrido = v_incurrido + v_tot_pagos;

	-- Solo Pagos

	let v_tot_pagos = 0;

	select x.cod_tipotran 
      into v_tipo
      from rectitra x
     where x.tipo_transaccion  = 4;

	select sum(x.monto) 
      into v_tot_pagos
      from rectrmae x, recrcmae y
     where y.no_poliza     = a_poliza
       and y.actualizado   = 1
       and x.no_reclamo    = y.no_reclamo
       and x.actualizado   = 1
       and x.cod_tipotran  = v_tipo;

	if v_tot_pagos is null then
	    let v_tot_pagos = 0;
    end if

	let _porc_partic = 0.00;

	foreach

		select porc_partic_agt,
			   cod_agente
		  into _porc_partic,
		       _cod_agente
		  from emipoagt
		 where no_poliza = a_poliza
		 order by porc_partic_agt desc

		exit foreach;

	end foreach

	return a_poliza, 
		   v_documento, 
		   v_factura, 
		   v_renovar, 
		   v_cod_renovar,
       	   v_cod_no_renovar,
       	   v_vigencia_inic, 
       	   v_vigencia_fin, 
       	   v_saldo, 
       	   v_cantidad, 
       	   v_incurrido,
       	   v_tot_pagos,
		   _cod_agente
       	   with resume;

end foreach

end

end procedure;
