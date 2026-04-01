-- Procedimiento que genera las cancelaciones por lote de las polizas con saldo dados por VPE
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado : 20/09/2016 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par184;
create procedure sp_par184()
returning integer,
          char(100);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _saldo			dec(16,2);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _no_factura		char(10);
define _periodo			char(7);
define _estatus_poliza	smallint;
define _ramo_2          char(2);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _descripcion		char(50);
define _cantidad		integer;
define _cod_pagador		char(10);
define _user_added		char(8);
define _facultativo     smallint;

--set debug file to "sp_par184.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

let _cantidad    = 0;
let _facultativo = 0;
let _user_added = "GERENCIA";
let _periodo    = "2026-03";

-- el procedure sp_par333 borra los duplicados
--RECORDAR QUE HAY POLIZAS CON PRIMA BRUTA = 0, A ESAS SE LE COLOCA EL VALOR DEL SALDO QUE DICE LA TABLA, EN EMIPOCOB PARA QUE SE REALICE LA CANCELACION.

--SET DEBUG FILE TO "sp_par184.trc"; 
--trace on;

foreach	with hold
	select distinct poliza
	  into _no_documento
	  from deivid_tmp:temp_venc2023may
	 where cancelada = 0
	   and prima_bruta <> 0
	 order by poliza
	
	let _ramo_2 = _no_documento[1,2];
	let _cantidad  = _cantidad + 1;
	if _ramo_2 = "19" then
		let _no_poliza = sp_sis21adm(_no_documento);	--Busca el no_poliza con saldo anterior, por temas de serie en el reaseguro.
	else
		let _no_poliza = sp_sis21(_no_documento);	--Busca el no_poliza ult. vigencia
	end if
	let _saldo = sp_cob174(_no_documento);

	select estatus_poliza
	  into _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	begin work;

		-- Solicitud de Jesica Miller
		-- No cancelar polizas que se encuentran vigentes
		-- 20 / Mayo / 2013
		-- Demetrio Hurtado	Almanza

		if _estatus_poliza <> 1 then -- Vigentes

			if _saldo > 0 then 

				-- Verifica que exista emireama y emireaco

				delete from emireaco
				 where no_poliza         = _no_poliza
				   and porc_partic_suma  = 0
				   and porc_partic_prima = 0;

				call sp_pro159(_no_poliza) returning _error, _descripcion;

				if _error <> 0 then
					rollback work;
					return _error, _cantidad || " Registros " || trim(_no_documento) || " " || _descripcion with resume;
					continue foreach;
				end if

				-- Actualiza los datos de la Poliza

				foreach	
				 select no_unidad
				   into _no_unidad
				   from emipouni
				  where no_poliza = _no_poliza

					call sp_proe02(_no_poliza, _no_unidad, "001") returning _error;

					if _error <> 0 then
						rollback work;
						return _error, _cantidad || " Registros " || trim(_no_documento) || " " || "Actualizando los Datos de la Unidad (sp_proe02)" with resume; 
						continue foreach;
					end if

				end foreach

				call sp_proe03(_no_poliza, "001") returning _error;

				if _error <> 0 then
					rollback work;
					return _error, _cantidad || " Registros " || trim(_no_documento) || " " || "Actualizando los Datos de la Poliza (sp_proe03)" with resume; 
					continue foreach;
				end if

				-- Actualiza el endoso

				update emipomae
				   set estatus_poliza = 1
				 where no_poliza      = _no_poliza;
				 
				update emipoliza
				   set fecha_suspension = null
				 where no_documento     = _no_documento;	--Se saca de suspension para poder cancelar

				-- Proceso de Renovacion

				let _error = sp_sis61d(_no_poliza);

				if _error <> 0 then
					rollback work;
					return _error, _cantidad || " Registros " || trim(_no_documento) || " " || "No Se Pudo Eliminar del Proceso de Renovacion" with resume; 
					continue foreach;
				end if
						 
				call sp_par130(_no_poliza, _user_added, _saldo) returning _error, _descripcion, _no_endoso;

				if _error <> 0 then
					rollback work;
					return _error, _cantidad || " Registros " || trim(_no_documento) || " " || _descripcion with resume; 
					continue foreach;
				end if

				-- Actualizaciones

				select no_factura,
				       prima_bruta
				  into _no_factura,
				       _prima_bruta
				  from endedmae
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso;

				if _prima_bruta > 0.1 then
					rollback work;
					let _descripcion = "Prima Bruta Errada " || _prima_bruta;
					return 1, _cantidad || " Registros " || trim(_no_documento) || " " || _descripcion with resume; 
					continue foreach;
				end if

				select cod_pagador
				  into _cod_pagador
				  from emipomae
				 where no_poliza = _no_poliza;

				insert into cobgesti(
				no_poliza,
				fecha_gestion,
				desc_gestion,
				user_added,
				no_documento,
				fecha_aviso,
				tipo_aviso,
				cod_gestion,
				cod_pagador
				)
				values(
				_no_poliza,
				current,
				"CANCELACION DE LA POLIZA POR AJUSTE ADMINISTRATIVO",
				_user_added,
				_no_documento,
				null,
				0,
				null,
				_cod_pagador
				);
			else

				let _no_factura = "00-00000";

			end if
		
		else

			let _no_factura = "00-00000";

		end if

		-- Actualizaciones Finales 
				
		update deivid_tmp:temp_venc2023may
		   set cancelada  = 1,
		       no_factura = _no_factura,
			   saldo      = _saldo,
			   estatus    = _estatus_poliza
		 where poliza     = _no_documento;

		if _no_factura <> "00-00000" then

			update endedmae
			   set periodo    = _periodo
			 where no_factura = _no_factura;

			update endedhis
			   set periodo    = _periodo
			 where no_factura = _no_factura;
			 
			--*****Insersion a tabla nota_cesion para polizas facultativas para el envio de la nota de cesion por correo Armando 14/11/2017.
			let _facultativo = 0;
			select facultativo
			  into _facultativo
			  from endedmae
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;
			   
			if _facultativo = 1 then
				insert into nota_cesion(no_poliza,no_endoso,enviado)
				values(_no_poliza,_no_endoso,0);
			end if
			--*****************************************************************
	
		end if
	commit work;
	if _cantidad >= 25 then
		exit foreach;
	end if
end foreach
end 
return 0, "Actualizacion Exitosa " || _cantidad || " Registros Procesados"; 
end procedure