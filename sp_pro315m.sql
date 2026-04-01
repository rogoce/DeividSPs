--- ****Renovacion Automatica. Proceso de excepciones ****
--- Creado 02/03/2009 por Armando Moreno
--- Modificado 17/06/2009 por Henry


drop procedure sp_pro315m;
create procedure sp_pro315m(v_periodo char(7))
returning integer,char(50);

begin

define _error_desc			char(50);
define v_documento			char(20);
define _cod_manzana			char(15);
define _cod_asegurado		char(10);
define _no_poliza			char(10);
define v_factura			char(10);
define v_poliza				char(10);
define _usuario				char(8);
define _usu_cob				char(8);
define _cod_cobertura		char(5);
define _cod_acreedor		char(5);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define v_cod_no_renovar		char(3);
define _codigo_agencia		char(3);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _centro_costo		char(3);
define _cod_tipoprod		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define v_tipo				char(3);
define _tipo_agente			char(1);
define _tipo_ramo			char(1);
define _porc_partic			dec(5,2);
define _suma_asegurada		dec(16,2);
define _prima_bruta			dec(16,2);
define v_tot_pagos			dec(16,2);
define v_incurrido			dec(16,2);
define _diezporc			dec(16,2);
define v_saldo				dec(16,2);
define v_pagos				dec(16,2);
define _saldo				dec(16,2);
define _todas_perdida		smallint;
define v_cod_renovar		smallint;
define _perd_total			smallint;
define v_cantidad			smallint;
define _saber_agt			smallint;
define _cantidad			smallint;
define v_renovar			smallint;
define _bandera				smallint;
define _estatus				smallint;
define _renglon				smallint;
define _renueva				smallint;
define v_cant				smallint;
define _canti				smallint;
define _salir				smallint;
define _activo				smallint;
define _error2				smallint;
define _cnt2				smallint;
define _cnt3				smallint;
define _cnt					smallint;
define _error_isam			integer;
define _error				integer;
define _edad				integer;
define _fecha_aniversario	date;
define _vigencia_fin_pol	date;
define v_vigencia_inic		date;
define _vig_inic_ult		date;
define v_vigencia_fin		date;
define _vig_final			date;
define _fecha				date;

on exception set _error, _error_isam, _error_desc
   return _error, _error_desc;
end exception

set isolation to dirty read;

let v_cod_renovar    = 0;
let _prima_bruta     = 0;
let v_incurrido      = 0;
let v_cantidad       = 0;
let v_renovar        = 0;
let _bandera         = 0;
let _renueva         = 1;
let v_pagos          = 0;
let v_saldo          = 0;
let _canti           = 0;
let _salir 			 = 0;
let v_cod_no_renovar = NULL;
let v_factura        = NULL;
let v_poliza         = NULL;
let _fecha           = current;
let _error2          = 1;

--SET DEBUG FILE TO "sp_pro315.trc"; 
--TRACE ON;                                                                

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
		   cod_ramo,
		   cod_tipoprod,
		   cod_grupo,
		   cod_subramo,
		   suma_asegurada,
		   prima_bruta,
		   vigencia_fin_pol
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
		   _cod_ramo,
		   _cod_tipoprod,
		   _cod_grupo,
		   _cod_subramo,
		   _suma_asegurada,
		   _prima_bruta,
		   _vigencia_fin_pol
	  from emipomae
	 where year(vigencia_final)		= v_periodo[1,4]
	   and month(vigencia_final)	= v_periodo[6,7]
	   and renovada					= 0
	   and no_renovar				= 0
	   and incobrable				= 0
	   and abierta					= 0
	   and actualizado				= 1
	   and no_documento             = '1522-00015-01'
	   and estatus_poliza			in (1,3)

	select count(*)
	  into _canti
	  from emirepo
	 where no_poliza = v_poliza;

	if _canti > 0 then
		continue foreach;
	end if 

   { let _bandera = 0;	se quito el 10/08/2010 a peticion de Rosa Y vielka debido a que quieren a estos corredores como una excepcion dentro del proceso

	 let _renueva = 1;

	 foreach

		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = v_poliza

		select tipo_agente,renueva
		  into _tipo_agente,_renueva
		  from agtagent
		 where cod_agente = _cod_agente;

		if _tipo_agente = 'E' and _renueva = 0 then

		   let _bandera = 1;
		   exit foreach;
		   	
		end if

	 end foreach

     if _bandera = 1 then
		continue foreach;
     end if }

	if _cod_ramo in('019') then
		if v_vigencia_fin = _vigencia_fin_pol then
		--Se marca con el motivo de Expiracion de termino, Gerogina solicitud 5/6/2012
			Update emipomae 
			   Set cod_no_renov		= "024",
				   fecha_no_renov	= Today,
				   user_no_renov	= "informix",
				   no_renovar		= 1
			 Where no_poliza		= v_poliza;

			continue foreach;
		end if
	end if

	if _cod_ramo = '018' then  --excluir por ahora este ramo (salud)
		continue foreach;
	end if
    if _cod_ramo = '020' then  --excluir SODA con corredor Ducruet correo 20/09/2012 enviado por Demetrio.
		let _saber_agt = 0;
		foreach
			select count(*)
			  into _saber_agt
			  from emipoagt
			 where no_poliza  = v_poliza
			   and cod_agente = '00035'
			exit foreach;
		end foreach

		if _saber_agt = 1 then	--Es Ducruet, no debe entrar al proceso
			continue foreach;
		end if
	end if
	if _cod_ramo = '008' then --FIANZAS
		if _cod_subramo not in("027","005","026","022","028","006","016","018","003","004","024","020","021","025","023","001") then
			continue foreach;
		end if
	end if

	let _error2 = sp_pro316(v_poliza,v_periodo);
	
	if _error2 <> 0 then
		return 1,'Error en Excepciones';
	end if
end foreach

if _error2 = 1 then
	return 0,'Proceso Terminado';
end if

foreach
	select no_poliza
	  into v_poliza
	  from tmp_reaut
	 group by no_poliza

	select no_documento, 
		   no_factura,
	       renovada, 
	       no_renovar, 
	       cod_no_renov,
	       vigencia_inic, 
	       vigencia_final, 
	       saldo,
		   cod_compania,
		   cod_sucursal,
		   cod_ramo,
		   cod_tipoprod,
		   cod_grupo,
		   cod_subramo,
		   suma_asegurada
	  into v_documento, 
		   v_factura, 
		   v_renovar, 
		   v_cod_renovar,
	       v_cod_no_renovar, 
	       v_vigencia_inic, 
	       v_vigencia_fin, 
	       v_saldo,
		   _cod_compania,
		   _cod_sucursal,
		   _cod_ramo,
		   _cod_tipoprod,
		   _cod_grupo,
		   _cod_subramo,
		   _suma_asegurada
	  from emipomae
	 where no_poliza = v_poliza;

	select centro_costo
	  into _centro_costo
	  from insagen
	 where codigo_agencia  = _cod_sucursal
	   and codigo_compania = _cod_compania;

	if _cod_ramo = "008" then
		let _usuario = sp_pro322(_centro_costo,'6',19);--Fianzas de levantamiento de secuestro
		update tmp_reaut
		   set usuario = _usuario
		 where no_poliza = v_poliza
		   and usuario  <> "AUTOMATI";
	end if

 	let _porc_partic = 0.00;

	foreach
		select porc_partic_agt,
			   cod_agente
		  into _porc_partic,
		       _cod_agente
		  from emipoagt
		 where no_poliza = v_poliza
		 order by porc_partic_agt desc
		exit foreach;
	end foreach

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

    delete from emirepo
     where no_poliza   = v_poliza;

    delete from emideren
     where no_poliza   = v_poliza;

    delete from emirepol
     where no_poliza   = v_poliza;

    select count(*) 
      into v_cantidad 
      from recrcmae
     where no_poliza   = v_poliza
       and actualizado = 1;

	if v_cantidad is null then
		let v_cantidad = 0;
	end if

	-- Pagos, Salvamentos, Recuperos y Deducibles

	let v_tot_pagos = 0;
	foreach
		select cod_tipotran 
		  into v_tipo
		  from rectitra
		 where tipo_transaccion  IN (4,5,6,7)

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

	select cod_tipotran 
      into v_tipo
      from rectitra
     where tipo_transaccion  = 4;

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
	select count(*)
	  into _cantidad
	  from emirepo
	 where no_poliza = v_poliza;

	if _cantidad = 0 then
		select count(*)
		  into _cnt
		  from tmp_reaut
		 where no_poliza = v_poliza;

		select count(*)
		  into _cnt2
		  from tmp_reaut
		 where no_poliza = v_poliza
		   and tipo_ramo = '5';	   --solo de sistema
		   --and renglon not in (51,52,12)		En espera de respuesta de Georgina para tratar las excepciones por notas como una excepcion que no es de sistema. Roman

		select count(*)
		  into _cantidad
		  from tmp_reaut
		 where no_poliza = v_poliza;

		select count(*)
		  into _cnt3
		  from tmp_reaut
		 where no_poliza = v_poliza
		   and renglon   = 11;	  --saldo cobros

		if _cnt3 > 0 then
			if _cod_ramo = "008" then
				select usuario_cobro_f
				  into _usu_cob
				  from emirepar;				
			else
				select usuario_cobros
				  into _usu_cob
				  from emirepar;
			end if
		else
			let _usu_cob = null;
		end if

		if _cantidad > 1 then
			foreach
				select count(*),
					   tipo_ramo
				  into _cantidad,
					   _tipo_ramo
				  from tmp_reaut
				 where no_poliza = v_poliza
				 group by 2
				 order by 1 desc
		  	   exit foreach;
			   --and tipo_ramo <> "5"	--diferente de sistema
			end foreach

			foreach
				select usuario
				  into _usuario
				  from tmp_reaut
				 where no_poliza = v_poliza
				   and tipo_ramo = _tipo_ramo
				 order by gerarquia
				exit foreach;
			end foreach
		else
			select usuario
		     into _usuario
		     from tmp_reaut
		    where no_poliza = v_poliza;
		end if
		
		let v_saldo = sp_cob115b('001','001',v_documento,'');
		if v_saldo is null then
			let v_saldo = 0;
		end if

		if _cnt = _cnt2 then			 --solo tiene excepcion de sistema.

			if _cod_ramo in("001","003","010","011") then
				let _usuario = sp_pro322(_centro_costo,'5',51);
			elif _cod_ramo in("005","006","007","009","015","004","017") then
				let _usuario = sp_pro322(_centro_costo,'5',52);
			else
				let _usuario = sp_pro322(_centro_costo,'5',13);
			end if

			let _estatus = 4;

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
					porc_depreciacion,
					cod_agente,
					estatus)
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
					0.00,
					_cod_agente,
					_estatus);
		end if

		if _usuario = 'AUTOMATI' then
			let _estatus = 1;
		else
			if _cnt = _cnt2 then
				let _estatus = 4;
			else
				let _estatus = 2;
			end if
		end if

		if _cnt = _cnt2 then --solo tiene de sistema, debe ir a renovacion manual solamente, no al pool.
			continue foreach;
		end if

		INSERT INTO emirepo(
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
		porc_depreciacion,
		cod_agente,
		estatus,
		cod_sucursal,
		user_cobros
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
		0.00,
		_cod_agente,
		_estatus,
		_centro_costo,
		_usu_cob
	    );
		foreach
			select renglon
			  into _renglon
			  from tmp_reaut
			 where no_poliza = v_poliza
			   and usuario   <> 'AUTOMATI'

			INSERT INTO emideren(no_poliza,renglon) VALUES (v_poliza,_renglon);
		end foreach
	else
		continue foreach;
	end if
end foreach


drop table tmp_reaut;

end
return 0,'Proceso Terminado';
end procedure;
