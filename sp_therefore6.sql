-- Procedure para cargar tablas temporales en deivid_tmp para luego ser pasadas por ODBC a SQLSERVER
-- 
-- Creado    : 19/12/2016 - Autor: Armando Moreno M.
--

drop procedure sp_therefore6;
create procedure sp_therefore6(a_no_poliza char(10), a_no_endoso char(5))
returning	char(20),
            char(5),
			char(10),
			char(30),
			varchar(100),
			date,
			char(50),
			smallint; 

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
define _cod_agente			char(10);
define _no_endoso			char(10);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _consecutivo			smallint;
define _cnt					smallint;
define _error_isam			integer;
define _error_cod			integer;
define _cod_error			integer;
define _error				integer;
define _ano					integer;
define _fecha_aniversario	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;

set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	--rollback work;
	return _error_cod, _error_desc;
end exception

--set debug file to 'sp_therefore6.trc';
--trace on;

let _fecha_hoy = current - 1 units day;	--Se resta 1 día porque el proceso diario se ejecuta en la madrugada.

foreach
	select no_factura,
		   no_poliza,
		   no_endoso,
		   cod_endomov,
		   no_documento
	  into _no_factura,
		   _no_poliza,
		   _no_endoso,
		   _cod_endomov,
		   _no_documento
	  from endedmae
	 where fecha_emision = _fecha_hoy
	   and actualizado = 1

	select count(*)
	  into _cnt_factura
	  from inf_facturas
	 where factura = _no_factura;

	if _cnt_factura is null then
		let _cnt_factura = 0;
	end if

	if _cnt_factura = 0 then

		select cod_contratante,
			   vigencia_inic,
			   vigencia_final
		  into _cod_cliente,
			   _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza;

		select cedula,
			   nombre
		  into _cedula,
			   _n_contratante
		  from cliclien
		 where cod_cliente = _cod_cliente;

		if _cod_endomov = '011' then
			begin
				on exception in(-239,-268)
				end exception

				insert into inf_polizas(
						no_documento,
						contratante,
						corredor,
						cedula,
						nuevo)
				values(	_no_documento,
						_n_contratante,
						_n_agente,
						_cedula,
						0);
			end
		end if

		let _llave = '';
		call sp_therefore0(_no_poliza,_no_endoso,'00000',_cod_cliente,'FACT') returning _error,_llave;

		begin
			on exception in (-239,-268)				
			end exception

			insert into inf_facturas(
					factura,
					no_documento,
					llave_int,
					cedula,
					vigencia_inic,
					vigencia_final,
					nuevo)
			values(	_no_factura,
					_no_documento,
					_llave,
					_cedula,
					_vigencia_inic,
					_vigencia_final,
					0);
		end

		select count(*)
		  into _cnt
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		if _cnt is null then
			let _cnt = 0;
		end if

		if _cnt > 0 then
			foreach
				execute procedure sp_therefore2(_no_poliza,_no_endoso) into _cod_error,_no_factura,_no_unidad,_cod_cliente2,_llave,_consecutivo

				if _llave is null then
					return 1,'Llave null. no_poliza: ' || trim(_no_poliza) || ' no_endoso: ' || trim(_no_endoso) with resume;
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
							participantes,
							nuevo)
					values(	_no_documento,
							_no_unidad,
							_no_factura,
							_cedula2,
							_n_contratante2,
							_fecha_aniversario,
							_llave,
							_consecutivo,
							0);
				end
			end foreach				
		end if

		return 1, _no_factura;
	end if
end foreach
end
end procedure;