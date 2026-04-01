-- Procedimiento que carga los valores en las polizas para el reporte de margen de contribucion

-- Creado    : 21/04/2006 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/07/2014 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo026;

CREATE PROCEDURE "informix".sp_bo026()
returning integer,
          char(50);

define _no_documento	char(20);
define _no_poliza		char(10);

define _ano				smallint;
define _cod_tipoagru	char(2);
define _cod_agruan		char(2);
define _cod_agrusu		char(5);

define _cod_corredor	char(5);
define _cod_grupo		char(5);
define _cod_contrato	char(5);
define _sucursal_origen	char(3);
define _cod_agencia		char(3);
define _cod_ramo		char(3);
define _cod_vendedor	char(3);
define _nombre			char(50);

define _error_code		integer;
define _error_isam		integer;
define _error_desc		char(50);
define _error_des2		char(50);

define _cantidad		integer;
define _cant_reas		integer;
define _no_cambio		smallint;

set isolation to dirty read;

begin 
on exception set _error_code, _error_isam, _error_desc
	return _error_code, _error_desc; 
end exception

-- Se Cargan las Agrupaciones

-- call sp_bo027() returning _error_code, _error_desc;

--if _error_code <> 0 then
--	return _error_code, _error_desc; 
--end if

--delete from deivid_bo:bopoagru
--where no_documento = "0208-00449-01";

let _cantidad = 0;

--set debug file to "sp_bo026.trc";
--trace on;

foreach
 select	no_documento
   into _no_documento
   from emipoliza
--  where cod_agruan is null or cod_agrusu is null 

--  where no_documento = "0208-00449-01"

	let _error_des2 = "Procesando Poliza " || _no_documento;
	let _cantidad   = _cantidad + 1;
	let _no_poliza  = sp_sis21(_no_documento);
	let _cod_agrusu = null;

	foreach	
	 select cod_tipoagru,
	        ano,
			cod_agruan
	   into _cod_tipoagru,
	        _ano,
			_cod_agruan
	   from deivid_bo:boagruan
	  where ano = 2006
	  order by indice

		if _cod_tipoagru = "01" then -- Accionistas

			select cod_grupo
			  into _cod_grupo
			  from emipomae
			 where no_poliza = _no_poliza;

			select cod_agrusu
			  into _cod_agrusu
			  from deivid_bo:boagrusu
			 where ano        = _ano
			   and cod_agruan = _cod_agruan
			   and cod_deivid = _cod_grupo;
		
		elif _cod_tipoagru = "02" then -- Estado

			select cod_grupo
			  into _cod_grupo
			  from emipomae
			 where no_poliza = _no_poliza;

			select cod_agrusu
			  into _cod_agrusu
			  from deivid_bo:boagrusu
			 where ano        = _ano
			   and cod_agruan = _cod_agruan
			   and cod_deivid = _cod_grupo;

		elif _cod_tipoagru = "03" then -- Fronting

			select max(no_cambio)
			  into _no_cambio
			  from emireama
			 where no_poliza = _no_poliza;

			select count(*)
			  into _cant_reas
			  from emireaco
			 where no_poliza = _no_poliza
			   and no_cambio = _no_cambio;

			if _cant_reas = 0 then

				foreach
				 select cod_contrato
				   into _cod_contrato
				   from emifacon
				  where no_poliza         = _no_poliza
				    and no_endoso         = "00000"
					and porc_partic_prima <> 0.00
					
					select cod_agrusu
					  into _cod_agrusu
					  from deivid_bo:boagrusu
					 where ano        = _ano
					   and cod_agruan = _cod_agruan
					   and cod_deivid = _cod_contrato;

					if _cod_agrusu is not null then
						exit foreach;
					end if

				end foreach

			else

				foreach
				 select cod_contrato
				   into _cod_contrato
				   from emireaco
				  where no_poliza         = _no_poliza
				    and no_cambio         = _no_cambio
					and porc_partic_prima <> 0.00
					
					select cod_agrusu
					  into _cod_agrusu
					  from deivid_bo:boagrusu
					 where ano        = _ano
					   and cod_agruan = _cod_agruan
					   and cod_deivid = _cod_contrato;

					if _cod_agrusu is not null then
						exit foreach;
					end if

				end foreach

			end if

		elif _cod_tipoagru = "04" then -- Sucursales

			select sucursal_origen
			  into _sucursal_origen
			  from emipomae
			 where no_poliza = _no_poliza;

			select cod_agrusu
			  into _cod_agrusu
			  from deivid_bo:boagrusu
			 where ano        = _ano
			   and cod_agruan = _cod_agruan
			   and cod_deivid = _sucursal_origen;

		elif _cod_tipoagru = "05" then -- Grupos

			select cod_grupo
			  into _cod_grupo
			  from emipomae
			 where no_poliza = _no_poliza;

			select cod_agrusu
			  into _cod_agrusu
			  from deivid_bo:boagrusu
			 where ano        = _ano
			   and cod_agruan = _cod_agruan
			   and cod_deivid = _cod_grupo;

		elif _cod_tipoagru = "06" then -- Corredor

			foreach
			 select cod_agente
			   into _cod_corredor
			   from emipoagt
			  where no_poliza = _no_poliza

				select cod_agrusu
				  into _cod_agrusu
				  from deivid_bo:boagrusu
				 where ano        = _ano
				   and cod_agruan = _cod_agruan
				   and cod_deivid = _cod_corredor;

				exit foreach;

			end foreach

		elif _cod_tipoagru = "07" then -- Fianzas

			select cod_ramo
			  into _cod_ramo
			  from emipomae
			 where no_poliza = _no_poliza;

			select cod_agrusu
			  into _cod_agrusu
			  from deivid_bo:boagrusu
			 where ano        = _ano
			   and cod_agruan = _cod_agruan
			   and cod_deivid = _cod_ramo;

		elif _cod_tipoagru = "08" then -- Promotorias

			select cod_ramo,
			       sucursal_origen
			  into _cod_ramo,
			       _sucursal_origen
			  from emipomae
			 where no_poliza = _no_poliza;

			select sucursal_promotoria
			  into _cod_agencia
			  from insagen
			 where codigo_agencia  = _sucursal_origen
			   and codigo_compania = "001";

			foreach
			 select cod_agente
			   into _cod_corredor
			   from emipoagt
			  where no_poliza = _no_poliza
				exit foreach;
			end foreach

			select cod_vendedor
			  into _cod_vendedor
			  from parpromo
			 where cod_agente  = _cod_corredor
			   and cod_agencia = _cod_agencia
			   and cod_ramo    = _cod_ramo;

			select cod_agrusu
			  into _cod_agrusu
			  from deivid_bo:boagrusu
			 where ano        = _ano
			   and cod_agruan = _cod_agruan
			   and cod_deivid = _cod_vendedor;

		end if

		if _cod_agrusu is not null then
			exit foreach;
		end if
		
	end foreach

	if _cod_agrusu is not null then
	
--		update emipoliza
--		   set cod_agruan   = _cod_agruan,
--		       cod_agrusu   = _cod_agrusu
--	     where no_documento = _no_documento;

		insert into deivid_bo:bopoagru
		values (_no_documento, _cod_agruan, _cod_agrusu, _no_poliza); 

	end if

{
	if _cantidad > 1000 then
		exit foreach;
	end if
--}

end foreach

end

return _cantidad, "Actualizacion Exitosa";

end procedure