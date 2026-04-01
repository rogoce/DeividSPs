drop procedure sp_pro28f;

create procedure "informix".sp_pro28f(
a_no_poliza char(10)
)

--- Renovacion de Polizas una sola
--- Creado 21/03/2005 por Armando Moreno

begin

define v_poliza     	char(10);
define v_documento  	char(20);
define v_factura    	char(10);
define v_renovar    	smallint;
define v_cod_renovar 	smallint;
define v_cod_no_renovar char(3);
define _cod_ramo        char(3);
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
define _cod_compania   	char(3);
define _codigo_agencia	char(3);
define _cod_sucursal   	char(3);
define _centro_costo   	char(3);
define _usuario      	char(8);
define _cnt			  	smallint;
define _cantidad	  	smallint;
define _porc_partic  	decimal(5,2);
define _cod_agente   	char(5);

create temp table tmp_reno(
usuario		char(8),
cantidad	integer
) with no log;

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

foreach
 select no_poliza, 
		no_documento, 
		no_factura,
        renovada, 
        no_renovar, 
        cod_no_renov,
        vigencia_inic, 
        vigencia_final, 
        saldo,
		cod_compania,
		cod_sucursal,
		cod_ramo
   into v_poliza, 
 	    v_documento, 
 	    v_factura, 
 	    v_renovar, 
 	    v_cod_renovar,
        v_cod_no_renovar, 
        v_vigencia_inic, 
        v_vigencia_fin, 
        v_saldo,
		_cod_compania,
		_cod_sucursal,
		_cod_ramo
   from emipomae
  where no_poliza             = a_no_poliza
    and renovada       		  = 0
    and no_renovar     		  = 0
    and incobrable     		  = 0
    and abierta        		  = 0
    and actualizado           = 1
    and estatus_poliza 		  IN (1,3)

	-- centro de costo, para determinar el usuario(emireusu)

	 select centro_costo
	   into _centro_costo
	   from insagen
	  where codigo_agencia  = _cod_sucursal
		and codigo_compania = _cod_compania;

	 select count(*)
	   into _cnt
	   from emireusu
	  where cod_sucursal = _centro_costo
	    and cod_ramo     = _cod_ramo;

	 if _cnt = 0 Then
	 	continue foreach;
	 end If
	 if _cnt = 1 then
		 select usuario
		   into _usuario
		   from emireusu
		  where cod_sucursal = _centro_costo
		    and cod_ramo     = _cod_ramo;
	 end if
	 if _cnt > 1 then
		foreach
		 select	usuario
		   into	_usuario
		   from emireusu
		  where cod_sucursal = _centro_costo
		    and cod_ramo     = _cod_ramo

			select count(*)
			  into _cantidad
			  from emirepol
			 where user_added = _usuario;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			insert into tmp_reno
			values (_usuario, _cantidad);

		end foreach

		foreach
		 select cantidad,
		        usuario
		   into _cantidad,
		        _usuario
		   from tmp_reno
		  order by 1, 2

			exit foreach;

		end foreach

		delete from tmp_reno;
	 end if

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

	{let v_cant = 0;

	select count(*)
      into v_cant 
      from emirepol
     where no_poliza  = v_poliza
       and user_added <> v_usuario;

	if v_cant > 0 Then
		continue foreach;
	end If}

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

	if v_tot_pagos is null then
	    let v_tot_pagos = 0;
    end if

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

	INSERT INTO emirepol(
	no_poliza,
	user_added,
	cod_no_renov,
	no_documento,
	renovar,
	no_renovar,
	fecha_selec,
	vigencia_inic,
	vigencia_final,
	saldo,
	cant_reclamos,
	no_factura,
	incurrido,
	pagos,
	porc_depreciacion
	)
	VALUES(
	v_poliza,
	_usuario,
	v_cod_no_renovar,
    v_documento,
    v_cod_renovar,
    v_renovar,
	today,
    v_vigencia_inic, 
    v_vigencia_fin,
    v_saldo,
	v_cantidad,
    v_factura, 
    v_incurrido,
    v_tot_pagos,
	0.00
    );

end foreach
drop table tmp_reno;
end

end procedure;
