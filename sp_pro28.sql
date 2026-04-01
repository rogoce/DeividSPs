drop procedure sp_pro28;

create procedure "informix".sp_pro28(
v_usuario char(8),
v_ramo    char(3),
v_periodo char(7),
v_grupo   char(5) default "*"
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
            decimal(16,2);

--- Renovacion de Polizas
--- Modificado 13/08/2001 por Armando Moreno
--- Se mod. para excluir de la pantalla de renovacion aquella poliza
--- que tuviese TODAS sus unidades marcadas como perdida total

--return v_poliza, v_documento,  v_factura, v_renovar, v_no_renovar,
--       v_cod_no_renovar,
--       v_vigencia_inic, v_vigencia_fin, v_saldo, v_cantidad, v_incurrido,
--       v_pagos
--  with resume;

begin

define v_poliza     	char(10);
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

set isolation to dirty read;

let v_pagos          = 0;
let v_incurrido      = 0;
let v_cantidad       = 0;
let v_saldo          = 0;
let v_renovar        = 0;
let v_cod_renovar    = 0;
let v_poliza         = NULL;
let v_factura        = NULL;
let v_cod_no_renovar = NULL;

if v_grupo is null Or v_grupo = " " Then
   let v_grupo = "*";
end if

foreach
 select emipomae.no_poliza, 
		emipomae.no_documento, 
		emipomae.no_factura,
        emipomae.renovada, 
        emipomae.no_renovar, 
        emipomae.cod_no_renov,
        emipomae.vigencia_inic, 
        emipomae.vigencia_final, 
        emipomae.saldo
   into v_poliza, 
 	    v_documento, 
 	    v_factura, 
 	    v_renovar, 
 	    v_cod_renovar,
        v_cod_no_renovar, 
        v_vigencia_inic, 
        v_vigencia_fin, 
        v_saldo
   from emipomae
  where emipomae.cod_ramo              = v_ramo
    and emipomae.cod_grupo             matches v_grupo
    and year(emipomae.vigencia_final)  = v_periodo[1,4]
    and month(emipomae.vigencia_final) = v_periodo[6,7]
    and emipomae.renovada              = 0
    and emipomae.no_renovar            = 0
    and emipomae.incobrable            = 0
    and emipomae.abierta               = 0
    and emipomae.actualizado           = 1
    and emipomae.estatus_poliza        IN (1,3)

	-- Excluir la poliza si todas las unidades son perdida

    let _todas_perdida = 1;
	foreach
	 select perd_total 
	   into _perd_total
	   from emipouni
	  where no_poliza = v_poliza
		if _perd_total = 0 then
			let _todas_perdida = 0;
			exit foreach;
		end if
	end foreach

	if _todas_perdida = 1 then
		continue foreach;
	end if

	-- No Incluir la Poliza si fue Seleccionada por Otros Usuario

	let v_cant = 0;

	select count(*)
      into v_cant
      from emirepol
     where no_poliza  = v_poliza
       and user_added <> v_usuario;

	if v_cant > 0 Then
		continue foreach;
	end If

    delete from emirepol
     where no_poliza   = v_poliza;

	let v_cantidad = 0;
    select count(*) 
      into v_cantidad 
      from recrcmae
     where recrcmae.no_poliza   = v_poliza
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
         where y.no_poliza     = v_poliza
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
     where y.no_poliza   = v_poliza
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
     where y.no_poliza     = v_poliza
       and y.actualizado   = 1
       and x.no_reclamo    = y.no_reclamo
       and x.actualizado   = 1
       and x.cod_tipotran  = v_tipo;

	if v_pagos is null then
	    let v_tot_pagos = 0;
    end if

	return v_poliza, 
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
       	   v_tot_pagos
       	   with resume;

end foreach

end

end procedure;
