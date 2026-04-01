-- Procedure para cargar tablas temporales en deivid_tmp para luego ser pasadas por ODBC a SQLSERVER
-- 
-- Creado    : 19/12/2016 - Autor: Armando Moreno M.
--

drop procedure sp_therefore1;
create procedure sp_therefore1(a_fecha_tope date)
returning	integer,
			varchar(100); 

define _n_contratante2	    varchar(100);
define _n_contratante	    varchar(100);
define _error_desc			varchar(50);
define _n_agente    		char(50);
define _mensaje				char(50);
define _llave				char(50);
define _cedula2				char(30);
define _cedula				char(30);
define _no_documento		char(20);
define _cod_cliente2		char(10);
define _cod_cliente			char(10);
define _no_factura			char(10);
define _no_poliza2			char(10);
define _cod_agente			char(10);
define _no_endoso			char(10);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _cod_ramo			char(3);
define _consecutivo			smallint;
define _cnt_existe			smallint;
define _cnt					smallint;
define _error_isam			integer;
define _error_cod			integer;
define _cod_error			integer;
define _error				integer;
define _ano					integer;
define _fecha_aniversario	date;
define _vigencia_inic		date;
define _vigencia_final		date;

set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	rollback work;
	return _error_cod, trim(_error_desc) || ' ' || _no_documento;
end exception

--set debug file to 'sp_therefore1.trc';
--trace on;

--let _no_documento = '1800-00035-01';
let _mensaje = 'Inserción Exitosa';

foreach with hold
	select no_documento,
		   cod_agente
	  into _no_documento,
		   _cod_agente
	  from emipoliza

	begin work;

	let _no_poliza = sp_sis21(_no_documento);

	select nombre
	  into _n_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select cod_contratante,
		   cod_ramo
	  into _cod_cliente,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select cedula,
		   nombre
	  into _cedula,
		   _n_contratante
	  from cliclien
	 where cod_cliente = _cod_cliente;

	begin
		on exception in(-239,-268)
		end exception

		insert into inf_polizas(
				no_documento,
				contratante,
				corredor,
				cedula)
		values(	_no_documento,
				_n_contratante,
				_n_agente,
				_cedula);
	end

	foreach
		select no_factura,
			   no_poliza,
			   no_endoso
		  into _no_factura,
			   _no_poliza2,
			   _no_endoso
		  from endedmae
		 where no_documento = _no_documento
		   and actualizado = 1
		   --and periodo >= '2016-01'
		   and fecha_emision >= '12/02/2017' 
		   and fecha_emision <= a_fecha_tope -- or (cod_endomov = '011' and fecha_emision <= '01/01/2012'))
		   and no_factura not in ('01-1058958','01-1059162','01-1060803','01-1075241','01-1111011','01-1116568','01-1117624','01-1121767','01-1121771','01-1121772','01-1121773','01-1121774','01-1121775','01-1121776','01-1121777','01-1121778','01-1126107',
								  '01-1126108','01-1126109','01-1126110','01-1126111','01-1126112','01-1126113','01-1126114','01-1126115','01-1164293','01-1262327','01-1262328','01-1396625','01-1414081','03-59158','09-07888','09-08560','09-08673','09-126827',
								  '09-127081','09-128289','09-128554','09-130144','09-138254','09-24201','09-25209','09-41639','09-57124','09-67057')
		 order by 1,3

		let _llave = '';
		call sp_therefore0(_no_poliza2,_no_endoso,'00000',_cod_cliente,'FACT') returning _error,_llave;

		select cedula
		  into _cedula
		  from cliclien
		 where cod_cliente = _cod_cliente;

		select vigencia_inic,
			   vigencia_final
		  into _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza2;

		begin
			on exception in (-239,-268)				
			end exception

			insert into inf_facturas(
					factura,
					no_documento,
					llave_int,
					cedula,
					vigencia_inic,
					vigencia_final)
			values(	_no_factura,
					_no_documento,
					_llave,
					_cedula,
					_vigencia_inic,
					_vigencia_final);
		end

		select count(*)
		  into _cnt
		  from endeduni
		 where no_poliza = _no_poliza2
		   and no_endoso = _no_endoso;

		if _cnt is null then
			let _cnt = 0;
		end if

		if _cnt > 0 then
			foreach
				execute procedure sp_therefore2(_no_poliza2,_no_endoso) into _cod_error,_no_factura,_no_unidad,_cod_cliente2,_llave,_consecutivo

				if _llave is null then
					return 1,'Llave null. no_poliza: ' || trim(_no_poliza2) || ' no_endoso: ' || trim(_no_endoso) with resume;
					continue foreach;
				end if

				select cedula,
					   nombre,
					   fecha_aniversario
				  into _cedula2,
					   _n_contratante2,
					   _fecha_aniversario
				  from cliclien
				 where cod_cliente = _cod_cliente2;

				{if _cod_ramo = '018' then
					select count(*)
					  into _cnt_existe
					  from inf_unidad
					 where no_documento = _no_documento
					   and unidad = _no_unidad
					   and cedula = _cedula2;
				else
					select count(*)
					  into _cnt_existe
					  from inf_unidad
					 where no_documento = _no_documento
					   and unidad = _no_unidad;
				end if

				if _cnt_existe is null then
					let _cnt_existe = 0;
				end if}
				
				begin
					on exception in(-239,-268)				
					end exception
					insert into inf_unidad(
							no_documento,
							unidad,
							factura,
							cedula,
							nombre,
							fecha_cumple,
							llave_int,
							participantes)
					values(	_no_documento,
							_no_unidad,
							_no_factura,
							_cedula2,
							_n_contratante2,
							_fecha_aniversario,
							_llave,
							_consecutivo);
				end
			end foreach				
		end if
	end foreach
	
	commit work;
end foreach
return _cnt, _mensaje;	

end
end procedure;