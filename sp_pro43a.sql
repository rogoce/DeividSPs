drop procedure sp_pro43a;
create procedure sp_pro43a(a_no_poliza char(10), a_no_endoso char(5), a_tipo_mov smallint)
returning	smallint,
			char(200);

define _error_desc			char(200);
define _mensaje				char(200);
define _no_fac_orig			char(10);
define _user_added			char(8);
define _periodo_end			char(7);
define _no_unidad			char(5);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_coasegur		char(3);
define _cod_endomov			char(3);
define _cod_tipocan			char(3);
define _cod_ramo			char(3);
define _error				smallint;
define _error_isam			smallint;
define _tipo_mov			smallint;
define _vigencia_final		date;
define _vigencia_inic		date;


--SET DEBUG FILE TO "sp_pro43a.trc";
--trace on;

set isolation to dirty read;
begin
on exception set _error
 	return _error, 'Error al Actualizar el Endoso ...';
end exception
let _no_fac_orig	= null;
let _tipo_mov		= a_tipo_mov;

select cod_compania,
	   cod_sucursal,
	   cod_endomov,
	   periodo,
	   vigencia_inic,
	   vigencia_final,
	   cod_tipocan,
	   no_factura,
	   user_added
  into _cod_compania,
	   _cod_sucursal,
	   _cod_endomov,
	   _periodo_end,
	   _vigencia_inic,
	   _vigencia_final,	
	   _cod_tipocan,
	   _no_fac_orig,
	   _user_added
  from endedmae
 where no_poliza   = a_no_poliza
   and no_endoso   = a_no_endoso
   and actualizado = 0;

if _tipo_mov = 10 then	-- modificacion de acreedores
	begin
		define _no_unidad		char(5);
		define _cod_acreedor	char(5);
		define _limite			dec(16,2);

		foreach
			select no_unidad
			  into _no_unidad
			  from	endeduni
			 where	no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso

			delete from emipoacr
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad;

			foreach 
				select cod_acreedor,
					   limite
				  into _cod_acreedor,
					   _limite
				  from endedacr
				 where no_poliza = a_no_poliza
				   and no_endoso = a_no_endoso
				   and no_unidad = _no_unidad

				insert into emipoacr(
						no_poliza, 
						no_unidad,
						cod_acreedor,
						limite)
				values(	a_no_poliza,
						_no_unidad,
						_cod_acreedor,
						_limite);
			end foreach
		end foreach
	end 	
elif _tipo_mov = 12 then		-- modificacion de corredores
	begin
		define _cod_agente	char(5);
		define _porc_partic	dec(5,2);
		define _porc_produc	dec(5,2);
		define _porc_comis	dec(5,2);
		define r_porc		dec(5,2);

		let	r_porc = 0.00;
		
		select sum(porc_partic_agt)
		  into	r_porc
		  from endmoage
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		if r_porc is null then
			let _mensaje = 'no ha colocado el corredor, verifique...';
			return 1, _mensaje;
		end if

		if r_porc <> 100.00 then
			let _mensaje = 'el porcentaje de participacion de los agentes debe sumar 100.00...';
			return 1, _mensaje;
		end if

		delete from emipoagt
		 where no_poliza = a_no_poliza;

		foreach
			select cod_agente, 
				   porc_partic_agt,
				   porc_comis_agt,
				   porc_produc
			  into _cod_agente, 
				   _porc_partic,
				   _porc_comis,
				   _porc_produc
			  from endmoage
			  where	no_poliza = a_no_poliza
			    and no_endoso = a_no_endoso

				insert into emipoagt(
						no_poliza,
						cod_agente,
						porc_partic_agt,
						porc_comis_agt,
						porc_produc)
				values	(a_no_poliza,
						_cod_agente, 
						_porc_partic,
						_porc_comis, 
						_porc_produc);
		end foreach
	end
elif _tipo_mov = 13 then		-- modificacion de asegurado
	begin
		define _desc_unidad		varchar(50);
		define _nombre			char(100);
		define _no_doc			char(20);
		define _no_tarjeta		char(19);
		define _no_cuenta		char(17);
		define _cod_cliente		char(10);
		define _cod_viejo		char(10);
		define _cod_grupo		char(5);
		define _cod_subramo		char(3);
		define _ramo_sis		smallint;
		define _por_certificado	smallint;
		define _tipo			smallint;
		define _cambiar_unidad	smallint;
		define _cant_unidad		smallint;
		define _camb_desc_uni	smallint;
		define _leasing			smallint;
		define _tiene_leasing	smallint;
				
		let _leasing = 0;
		let _tiene_leasing = 0;
		let _no_cuenta = null;
		let _no_tarjeta = null;
		
		select cod_cliente,
			   tipo,
			   leasing
		  into _cod_cliente,
			   _tipo,
			   _tiene_leasing
		  from endmoase
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

        if _tiene_leasing is null then
			let _tiene_leasing = 0;
		end if

		select nombre
		  into _nombre
		  from cliclien
		 where cod_cliente = _cod_cliente;

		select cod_ramo, 
			   por_certificado, 
			   cod_contratante,
			   leasing,
			   no_documento,
			   no_cuenta,
			   no_tarjeta,
			   cod_subramo,
			   cod_grupo
		  into _cod_ramo, 
		       _por_certificado, 
		       _cod_viejo,
			   _leasing,
			   _no_doc,
			   _no_cuenta,
			   _no_tarjeta,
			   _cod_subramo,
			   _cod_grupo
		  from emipomae
		 where no_poliza = a_no_poliza;

		select ramo_sis
		  into _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		let _cambiar_unidad = 1;
		let _camb_desc_uni  = 0;
		
		select count(*)
		  into _cant_unidad
		  from emipouni
		 where no_poliza = a_no_poliza;
		 
		if _ramo_sis = 7 then	   --colectivo de vida
			if _cant_unidad > 1 then
				let _cambiar_unidad = 0;
			else
				let _cambiar_unidad = 1;
			end if
			
			let _camb_desc_uni = 1;			
			if _cod_subramo = '002' and _cod_grupo = '01016' then
				let _cambiar_unidad = 1;
			end if
		end if
		
		if _ramo_sis = 1 then	   -- auto y soda
			if _cant_unidad > 1 then
				let _cambiar_unidad = 0;
			else
				let _cambiar_unidad = 1;
			end if			
			let _camb_desc_uni = 1;
		end if	
		
		if _ramo_sis = 5 then	   --salud
			let _cambiar_unidad = 0;
		end if
		
		if _ramo_sis = 9 then					   --acc. personales
			if _cant_unidad > 1 then
				let _cambiar_unidad = 0;
			end if
			let _camb_desc_uni = 1;
		end if		

		if _ramo_sis = 6 or _ramo_sis = 2 then	   --vida individual o incendio o multiriesgo
			let _camb_desc_uni = 1;
		end if
		
		if _camb_desc_uni = 1 then
			select nombre
			  into _desc_unidad
			  from cliclien
			 where cod_cliente = _cod_cliente;
		end if

		if _cambiar_unidad = 1 and _por_certificado = 1 then
			let _cambiar_unidad = 0;
		end if		

		if _cambiar_unidad = 1 then	  --una sola unidad
			if _tipo = 1 then	--ambos
                if _camb_desc_uni = 1 then
					update emipouni
					   set cod_asegurado = _cod_cliente,
					       desc_unidad   = _desc_unidad
					 where no_poliza     = a_no_poliza;
				else
					update emipouni
					   set cod_asegurado = _cod_cliente
					 where no_poliza     = a_no_poliza;
				end if

				update endeduni
				   set cod_cliente = _cod_cliente
				 where no_poliza   = a_no_poliza
				   and no_endoso   = '00000';

				update endeduni
				   set cod_cliente = _cod_cliente
				 where no_poliza   = a_no_poliza
				   and no_endoso   = a_no_endoso;

				update emipomae
				   set cod_contratante = _cod_cliente,
				       cod_pagador     = _cod_cliente
				 where no_poliza       = a_no_poliza;

				if _no_cuenta is not null then
				    update cobcutas
				       set nombre       = _nombre
				     where no_cuenta    = _no_cuenta
					   and no_documento = _no_doc;

				    update cobcuhab
				       set cod_pagador  = _cod_cliente,
					       nombre       = _nombre
				     where no_cuenta    = _no_cuenta;
				end if

				if _no_tarjeta is not null then
				    update cobtacre
				       set nombre       = _nombre
				     where no_tarjeta   = _no_tarjeta
					   and no_documento = _no_doc;

				    update cobtahab
				       set nombre     = _nombre
				     where no_tarjeta = _no_tarjeta;
				end if
			elif _tipo = 2 then	  --asegurado
                if _camb_desc_uni = 1 then
					update emipouni
					   set cod_asegurado = _cod_cliente,
					       desc_unidad   = _desc_unidad
					 where no_poliza     = a_no_poliza;
				else
					update emipouni
					   set cod_asegurado = _cod_cliente
					 where no_poliza     = a_no_poliza;
			    end if

				update endeduni
				   set cod_cliente = _cod_cliente
				 where no_poliza   = a_no_poliza
				   and no_endoso   = '00000';

				update endeduni
				   set cod_cliente = _cod_cliente
				 where no_poliza   = a_no_poliza
				   and no_endoso   = a_no_endoso;

				if _tiene_leasing = 1 then	--poner poliza como leasing
					update emipomae
					   set leasing   = 1
					 where no_poliza = a_no_poliza;

					let _leasing = 1;
				elif _tiene_leasing = 2 then  --quitar el leasing
					update emipomae
					   set leasing   = 0
					 where no_poliza = a_no_poliza;

					let _leasing = 0;
				end if

				if _leasing <> 1 then
					update emipomae
					   set cod_contratante = _cod_cliente
					 where no_poliza       = a_no_poliza;
				end if
			elif _tipo = 3 then	  --contratante
				update emipomae
				   set cod_pagador = _cod_cliente
				 where no_poliza   = a_no_poliza;
				 
				if _no_cuenta is not null then
				    update cobcuhab
				       set cod_pagador = _cod_cliente,
					       nombre      = _nombre
				     where no_cuenta   = _no_cuenta;
				end if
				
				if _no_tarjeta is not null then
				    update cobtahab
				       set nombre     = _nombre
				     where no_tarjeta = _no_tarjeta;
				end if
				
				if _tiene_leasing = 1 then	--poner poliza como leasing
					update emipomae
					   set leasing   = 1
					 where no_poliza = a_no_poliza;
					let _leasing = 1;
				elif _tiene_leasing = 2 then  --quitar el leasing
					update emipomae
					   set leasing   = 0
					 where no_poliza = a_no_poliza;
					let _leasing = 0;
				end if
				
				if _leasing = 1 then
					update emipomae
					   set cod_contratante = _cod_cliente
					 where no_poliza       = a_no_poliza;
				end if
			end if
	    end if
		
		select no_unidad
		  into _no_unidad
		  from endeduni
		 where no_poliza = a_no_poliza
	       and no_endoso = a_no_endoso;	--> aqui hay problemas que trae varias unidades
		   
		if _camb_desc_uni = 1 then
			select nombre
			  into _desc_unidad
			  from cliclien
			 where cod_cliente = _cod_cliente;
		end if
		
		if _tipo = 1 then     --ambos
			update emipomae
			   set cod_contratante = _cod_cliente,
			       cod_pagador     = _cod_cliente
			 where no_poliza       = a_no_poliza;

			if _no_cuenta is not null then
			    update cobcutas
			       set nombre       = _nombre
			     where no_cuenta    = _no_cuenta
				   and no_documento = _no_doc;

				update cobcuhab
				   set cod_pagador  = _cod_cliente,
				       nombre       = _nombre
				where no_cuenta    = _no_cuenta;
			end if
			
			if _no_tarjeta is not null then
				update cobtacre
				   set nombre       = _nombre
				 where no_tarjeta   = _no_tarjeta
				   and no_documento = _no_doc;
				update cobtahab
				   set nombre     = _nombre
				 where no_tarjeta = _no_tarjeta;
			end if
		elif _tipo = 2 then	  --asegurado
            if _camb_desc_uni = 1 then
				update emipouni
				   set cod_asegurado = _cod_cliente,
				       desc_unidad   = _desc_unidad
				 where no_poliza     = a_no_poliza
				   and no_unidad     = _no_unidad;
			else
				update emipouni
				   set cod_asegurado = _cod_cliente
				 where no_poliza     = a_no_poliza
				   and no_unidad     = _no_unidad;
			end if

			update endeduni
			   set cod_cliente = _cod_cliente
			 where no_poliza   = a_no_poliza
			   and no_endoso   = '00000'
			   and no_unidad   = _no_unidad;

			update endeduni
			   set cod_cliente = _cod_cliente
			 where no_poliza   = a_no_poliza
			   and no_endoso   = a_no_endoso;
		elif _tipo = 3 then	  --contratante
			update emipomae
			   set cod_pagador = _cod_cliente
			 where no_poliza   = a_no_poliza;

			if _leasing = 1 then
				update emipomae
				   set cod_contratante = _cod_cliente
				 where no_poliza       = a_no_poliza;
			end if
			
			if _no_cuenta is not null then
			    update cobcuhab
			       set cod_pagador  = _cod_cliente,
				       nombre       = _nombre
			     where no_cuenta    = _no_cuenta;
			end if
			
			if _no_tarjeta is not null then
			    update cobtahab
			       set nombre     = _nombre
			     where no_tarjeta = _no_tarjeta;
			end if
		end if
	end
elif _tipo_mov = 15 then		-- cambio de coaseguro
	begin
		define _no_cambio_char		char(3);
		define _cod_tipoprod1		char(3);
		define _cod_coasegur		char(3);
		define _cambio				char(3);
		define _porc_partic_coas	dec(7,4);
		define _porc_gastos			dec(5,2);
		define _no_cambio_int		smallint;
		define _cant_coas			smallint;
		
		select count(*)
		  into _no_cambio_int
		  from	endcamco
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;
		   
		if _no_cambio_int is null then
			let _no_cambio_int = 0;
		end if
		
		if _no_cambio_int = 0 then -- cambio para sin coaseguro
			delete from emicoama
			 where no_poliza = a_no_poliza;

			select cod_tipoprod
			  into _cod_tipoprod1
			  from emitipro
			 where tipo_produccion = 1;

			select max(no_cambio) 
			  into _cambio
			  from emihcmm
			 where no_poliza = a_no_poliza;

			update emihcmm 
			   set vigencia_final = _vigencia_inic
			 where no_poliza      = a_no_poliza
			   and no_cambio      = _cambio;
		else
			select par_ase_lider
			  into _cod_coasegur
			  from parparam
			 where cod_compania = _cod_compania;

			 select count(*)
			   into _no_cambio_int
			   from	endcamco
			  where no_poliza    = a_no_poliza
			    and no_endoso    = a_no_endoso
				and cod_coasegur = _cod_coasegur;

			if _no_cambio_int is null then
				let _no_cambio_int = 0;
			end if

			if _no_cambio_int = 0 then -- cambio en coaseguro minoritario
				delete from emicoama
				 where no_poliza = a_no_poliza;

				delete from emicoami
				 where no_poliza = a_no_poliza;

				select cod_tipoprod
				  into _cod_tipoprod1
				  from emitipro
				 where tipo_produccion = 3;

				insert into emicoami
				select a_no_poliza,
				       cod_coasegur
				  from endcamco
				 where no_poliza = a_no_poliza
				   and no_endoso = a_no_endoso;
			else					   -- cambio en coaseguro mayoritario
				select cod_tipoprod
				  into _cod_tipoprod1
				  from emitipro
				 where tipo_produccion = 2;

				select max(no_cambio) 
				  into _cambio
				  from emihcmm
				 where no_poliza = a_no_poliza;

				let _no_cambio_int = _cambio;

				if _no_cambio_int is null then
					let _no_cambio_int = 0;
				end if

				let _no_cambio_int  = _no_cambio_int + 1;
				let _no_cambio_char = '000';

				if _no_cambio_int > 99 then
					let _no_cambio_char[1,3] = _no_cambio_int;
				elif _no_cambio_int > 9 then
					let _no_cambio_char[2,3] = _no_cambio_int;
				else
					let _no_cambio_char[3,3] = _no_cambio_int;
				end if

				delete from emicoama
				 where no_poliza = a_no_poliza;

				update emihcmm 
				   set vigencia_final = _vigencia_inic
				 where no_poliza      = a_no_poliza
				   and no_cambio      = _cambio;

				insert into emihcmm(
						no_poliza,
						no_cambio,
						vigencia_inic,
						vigencia_final,
						fecha_mov,
						no_endoso)
				values	(a_no_poliza,
						_no_cambio_char,
						_vigencia_inic,
						_vigencia_final,
						current,
						a_no_endoso);
				foreach
					select cod_coasegur,    
						   porc_partic_coas,
						   porc_gastos     
					  into _cod_coasegur,    
						   _porc_partic_coas,
						   _porc_gastos     
					  from endcamco
					 where no_poliza = a_no_poliza
					   and no_endoso = a_no_endoso

					insert into emicoama(
							no_poliza,
							cod_coasegur,    
							porc_partic_coas,
							porc_gastos)
					values	(a_no_poliza,
							_cod_coasegur,
							_porc_partic_coas,
							_porc_gastos);

					insert into emihcmd(
							no_poliza,
							no_cambio,
							cod_coasegur,    
							porc_partic_coas,
							porc_gastos)
					values	(a_no_poliza,
							_no_cambio_char,
							_cod_coasegur,    
							_porc_partic_coas,
							_porc_gastos);
				end foreach
			end if
		end if

		update emipomae
		   set cod_tipoprod = _cod_tipoprod1
		 where no_poliza    = a_no_poliza;
	end
elif _tipo_mov = 17 then		-- cambio de reaseguro individual
	begin
		define _cod_contrato		char(5);
		define _no_unidad			char(5);
		define _cod_cober_reas		char(3);
		define _cod_coasegur		char(3);
		define _porc_comis_fac		dec(5,2);
		define _porc_impuesto		dec(5,2);
		define _porc_partic_suma	dec(9,6);
		define _porc_partic_prima	dec(9,6);
		define _porc_partic_reas	dec(9,6);
		define _prima_s				dec(16,2);
		define _no_cambio			smallint;
		define _orden				smallint;
		define _cant				smallint;
		define _vigencia_inic		date;
		define _vigencia_final		date;		

		let _prima_s = 0.00;
		
        select vigencia_inic,
			   vigencia_final,
			   prima_suscrita 
		  into _vigencia_inic,
			   _vigencia_final,
			   _prima_s
		  from endedmae	x
		 where x.no_poliza = a_no_poliza
		   and x.no_endoso = a_no_endoso;

		if _prima_s <> 0.00 then
			let _mensaje = 'prima suscrita debe ser cero, por favor verifique ...';
			return 1, _mensaje;
		end if
		
		foreach
			select	no_unidad 
			  into _no_unidad 
			  from	endeduni
			 where	no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso

            select max(x.no_cambio) 
              into _no_cambio
			  from emireama x
			 where x.no_poliza = a_no_poliza
			   and x.no_unidad = _no_unidad;

			if _no_cambio is null then
			   	let _no_cambio = 0;
			else
            	let _no_cambio = _no_cambio + 1;
			end if

			foreach
				select cod_cober_reas,
					   orden,
					   cod_contrato,
					   porc_partic_suma,
					   porc_partic_prima
				  into _cod_cober_reas,
					   _orden,
					   _cod_contrato,
					   _porc_partic_suma,
					   _porc_partic_prima
				  from emifacon
				 where no_poliza = a_no_poliza
				   and no_endoso = a_no_endoso
				   and no_unidad = _no_unidad
				
				let _cant = 0;

				select count(*) 
				  into _cant
				  from emireama x
				 where no_poliza      = a_no_poliza
				   and no_unidad      = _no_unidad
				   and no_cambio      = _no_cambio
				   and cod_cober_reas = _cod_cober_reas;

			    if _cant = 0 then
					insert into emireama(
							no_poliza,
							no_unidad,
							no_cambio, 
							cod_cober_reas,
							vigencia_inic, 
							vigencia_final)
				   values	(a_no_poliza,
							_no_unidad, 
							_no_cambio,
							_cod_cober_reas, 
							_vigencia_inic,
							_vigencia_final);
				end if

		  		insert into emireaco(
						no_poliza,
						no_unidad,
						no_cambio, 
						cod_cober_reas,
						orden,
						cod_contrato,
						porc_partic_suma, 
						porc_partic_prima)
		  		values	(a_no_poliza,
						_no_unidad,
						_no_cambio,
						_cod_cober_reas, 
						_orden,
						_cod_contrato,
						_porc_partic_suma,
						_porc_partic_prima);
				foreach
					select cod_coasegur,
						   porc_partic_reas,
						   porc_comis_fac,
						   porc_impuesto
					  into _cod_coasegur,
						   _porc_partic_reas,
						   _porc_comis_fac,
						   _porc_impuesto
					  from emifafac
					 where no_poliza      = a_no_poliza
					   and no_endoso      = a_no_endoso
					   and no_unidad      = _no_unidad
					   and cod_cober_reas = _cod_cober_reas
					   and orden          = _orden
					   and cod_contrato   = _cod_contrato
				
					insert into emireafa(
							no_poliza,
							no_unidad,
							no_cambio,
							cod_cober_reas,
							orden,
							cod_contrato,
							cod_coasegur,
							porc_partic_reas,
							porc_comis_fac,
							porc_impuesto)
					values	(a_no_poliza,
							_no_unidad,
							_no_cambio,
							_cod_cober_reas,
							_orden,
							_cod_contrato,
							_cod_coasegur,
							_porc_partic_reas,
							_porc_comis_fac,
							_porc_impuesto);
				end foreach
			end foreach
		end foreach
	end 
elif _tipo_mov = 19 then		-- disminucion de vigencia
	begin
		define _deducible		char(50);
		define _cod_cobertura	char(5);
		define _no_unidad		char(5);
		define _ls_cod_ramo		char(3);
		define _cambio			char(3);
		define _suma_asegurada	dec(16,2);
		define _prima			dec(16,2);
		define _prima_neta		dec(16,2);
		define _descuento		dec(16,2);
		define _recargo			dec(16,2);
		define _impuesto		dec(16,2);
		define _prima_bruta		dec(16,2);
		define _prima_anual		dec(16,2);
		define _limite_1		dec(16,2);
		define _limite_2		dec(16,2);
		define _renglon			smallint;

		call sp_sis57(a_no_poliza, a_no_endoso); -- informacion necesaria para bo
		
		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = a_no_poliza;
		 
		foreach
			select no_unidad, 
				   suma_asegurada,
				   prima,
				   prima_neta,
				   descuento,
				   recargo,
				   impuesto,
				   prima_bruta
			  into _no_unidad, 
				   _suma_asegurada, 
				   _prima,
				   _prima_neta,
				   _descuento,
				   _recargo,
				   _impuesto,
				   _prima_bruta
			  from endeduni
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso

			update emipouni
			   set suma_asegurada = suma_asegurada + _suma_asegurada,
			       prima          = prima          + _prima,
			       prima_neta     = prima_neta     + _prima_neta,
			       descuento      = descuento      + _descuento,
			       recargo        = recargo        + _recargo,
			       impuesto       = impuesto       + _impuesto,
			       prima_bruta    = prima_bruta    + _prima_bruta
			 where no_poliza      = a_no_poliza
			   and no_unidad      = _no_unidad;
			   	if _cod_ramo = '002' then
			   		call sp_imp11(a_no_poliza,_no_unidad);
				end if
			foreach 
				select cod_cobertura,
					   prima,
					   prima_neta,
					   descuento,
					   recargo,
					   prima_anual,
					   limite_1,
					   limite_2,
					   deducible
				  into _cod_cobertura,
					   _prima,
					   _prima_neta,
					   _descuento,
					   _recargo,
					   _prima_anual,
					   _limite_1,
					   _limite_2,
					   _deducible
				  from endedcob
				 where no_poliza = a_no_poliza
				   and no_endoso = a_no_endoso
				   and no_unidad = _no_unidad

				update emipocob
				   set prima         = prima       + _prima,
					   prima_neta    = prima_neta  + _prima_neta,
					   descuento     = descuento   + _descuento,
					   recargo	    = recargo     + _recargo,
					   limite_1	    = limite_1    + _limite_1,
					   limite_2	    = limite_2    + _limite_2,
					   deducible     = _deducible
				 where no_poliza     = a_no_poliza
				  and no_unidad     = _no_unidad
				  and cod_cobertura = _cod_cobertura;
			end foreach
 		end foreach

		select cod_ramo,
			   vigencia_final
		  into _ls_cod_ramo,
			   _vigencia_final
		  from emipomae
		 where no_poliza = a_no_poliza;
		   
		if _ls_cod_ramo <> "019" then
			update emipomae
			   set vigencia_final = _vigencia_inic
			 where no_poliza      = a_no_poliza;

			update emipouni
			   set vigencia_final = _vigencia_inic
			 where no_poliza      = a_no_poliza;
		else
			update emipomae
			   set vigencia_fin_pol = _vigencia_inic
			 where no_poliza        = a_no_poliza;
		end if

		select max(no_cambio) 
		  into _cambio 
		  from emihcmm
		 where no_poliza = a_no_poliza;

		if _cambio is not null then
			update emihcmm 
			   set vigencia_final = _vigencia_inic
			 where no_poliza      = a_no_poliza
			   and no_cambio      = _cambio;
		end if
	end
elif _tipo_mov = 20 then    -- cancelacion por saldo 
	begin
		define _cod_ubica	char(3);
		define _no_unidad	char(5);
		define _suma_inc	dec(16,2);
		define _prima_inc	dec(16,2);
		define _prima_ter	dec(16,2);
		define _suma_ter	dec(16,2);
		define _accion		smallint;
		define _opcion		smallint;
		
		select accion
		  into _accion
		  from endtican
		 where cod_tipocan = _cod_tipocan;

		update emipomae
		   set estatus_poliza    = _accion,
			   fecha_cancelacion = _vigencia_inic
		 where no_poliza         = a_no_poliza;
		 
		foreach
			select no_unidad
			  into _no_unidad
			  from endeduni
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso

			foreach 
				select cod_ubica, 
					   suma_incendio,
					   suma_terremoto,
					   prima_incendio,
					   prima_terremoto,
					   opcion
				  into _cod_ubica,
					   _suma_inc,
					   _suma_ter,
					   _prima_inc,
					   _prima_ter,
					   _opcion
				  from endcuend
				 where no_poliza = a_no_poliza
				   and no_endoso = a_no_endoso
				   and no_unidad = _no_unidad

				if _opcion = 2 then -- modificacion de cumulos
				   update emicupol
					  set suma_incendio   = suma_incendio   + _suma_inc,
						  suma_terremoto  = suma_terremoto  + _suma_ter,
						  prima_incendio  = prima_incendio  + _prima_inc,
						  prima_terremoto = prima_terremoto + _prima_ter
					where no_poliza       = a_no_poliza
					  and no_unidad       = _no_unidad
					  and cod_ubica       = _cod_ubica;
				end if
			end foreach
		end foreach
	end 
elif _tipo_mov = 24 or _tipo_mov = 25 then		-- descuento de pronto pago
	update endedcob
	   set deducible    = '0',
		   limite_1     = 0,
		   limite_2     = 0,
		   desc_limite1 = "",
		   desc_limite2 = ""  
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso;

	update endeduni  
	   set suma_asegurada = 0  
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso;

	update emifacon  
	   set suma_asegurada = 0  
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso;
elif _tipo_mov = 26 then		-- cambio de tipo de vehic.	 henry-16/03/2011
	begin
		define _no_unidad	char(5);
		define _cod_tipoveh	char(3);

		foreach	
			select no_unidad,
				   cod_tipoveh			   
			  into _no_unidad,
				   _cod_tipoveh
			  from endmoaut
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso

			if _no_unidad is not null then
				if _cod_tipoveh is not null then
					update emiauto
					   set cod_tipoveh = _cod_tipoveh
					 where no_poliza   = a_no_poliza
					   and no_unidad   = _no_unidad;
				else
					let _mensaje = 'No Existe Tipo de Vehiculo, Por Favor Actualice Nuevamente ...';
					return 1, _mensaje;
				end if
			else
				let _mensaje = 'No Existe Unidad, Por Favor Actualice Nuevamente ...';
				return 1, _mensaje;
			end if
		end foreach		
	end
elif _tipo_mov = 28 then		-- cambio de codigo de manzana.	federico 30/11/2012
	begin
		define _cod_manzana   char(50);

		select cod_manzana,
			   no_unidad
		  into _cod_manzana,
			   _no_unidad
		  from endeduni
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		if _cod_manzana is not null then
			update emipouni
			set cod_manzana = _cod_manzana
			where no_poliza = a_no_poliza
			and no_unidad = _no_unidad;
		else
			let _mensaje = 'No Existe codigo de manzana, Por Favor Actualice Nuevamente ...';
			return 1, _mensaje;
		end if	
	end
end if
return 0, 'Actualizacion Exitosa ...';
end
end procedure;