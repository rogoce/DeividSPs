-- Procedimiento que carga las coberturas de los prodcutos en el Proceso de Pre-Renovaciones.
-- Creado    : 11/02/2016 - Autor: Román Gordón
-- sis v.2.0 - deivid, s.a.

drop procedure sp_pro381a;
create procedure "informix".sp_pro381a(a_no_poliza char(10),a_no_unidad char(5))
returning   integer			as code_error,
			varchar(255)	as descripcion;   -- _error

define _sql_describe		lvarchar;
define _sql_where			lvarchar;
define _campo_desc_limite	varchar(50);
define _desc_limite1		varchar(50);
define _desc_limite2		varchar(50);
define _error_desc			varchar(50);
define _campo_deducible		varchar(30);
define _campo_limite		varchar(30);
define _campo_prima			varchar(30);
define _deducible			varchar(30);
define _no_documento		char(20);
define _cod_cobertura		char(5);
define _cod_producto		char(5);
define _cod_tipo_tar		char(3);
define _prima_neta			dec(16,2);
define _limite1   			dec(16,2);
define _limite2		   		dec(16,2);
define _error_isam			smallint;
define _cnt_cober			smallint;
define _error				smallint;

begin

on exception set _error,_error_isam,_error_desc
	let _error_desc = 'Excepcion DB.' || _error_desc;
 	return _error,_error_desc;         
end exception

set isolation to dirty read;

--set debug file to "sp_pro381a.trc";
--trace on;

let _prima_neta	= 0.00;
let _campo_deducible = '';
let	_campo_limite = '';
let _desc_limite1 = '';
let	_desc_limite2 = '';
let	_campo_prima = '';

--set debug file to "sp_pro368.trc";      
--trace on;

select no_documento
	   --cod_ramo,
	   --cod_subramo
  into _no_documento
	   --_cod_ramo,
	   --_cod_subramo
  from emipomae
 where no_poliza = a_no_poliza;

{select cod_producto,
	   cod_tipo_tar
  into _cod_producto,
	   _cod_tipo_tar
  from emipouni
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

select cod_marca,
	   cod_modelo
  into _cod_marca,
	   _cod_modelo
  from emiauto
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

let _desc_modelo = sp_proe81(_cod_marca, _cod_modelo);
let _desc_tabla = sp_proe72(a_no_poliza,a_no_unidad);
call sp_pro550(_no_documento) returning _no_documento, _no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro, _incurrido_bruto, _prima_devengada, _siniestralidad,	_desc_sinis, _condicion;

let _desc_tabla = sp_proe72(a_no_poliza,a_no_unidad);

if _tipo_auto = 1 and _cod_tipo_tar in ('001') and _no_sinis_ult = 0 then	--'002'
	let	_desc_tabla = 50;
	let _desc_sinis = 0.00;
else
	if _cod_ramo = '002' and _cod_subramo = '001' then	--Descuento por siniestralidad, solo Auto y subramo particular
		if _condicion = 1 then	--Condicion de recargo sobre el descuento
			let _desc_tabla = _desc_tabla - _desc_tabla * _desc_sinis / 100;
			let _desc_sinis = 0.00;
		end if
	end if
end if}

foreach
	select cod_cobertura,
		   deducible,
		   limite_1,
		   limite_2,
		   desc_limite1,
		   desc_limite2,
		   prima_neta
	  into _cod_cobertura,
		   _deducible,
		   _limite1,
		   _limite2,
		   _desc_limite1,
		   _desc_limite2,
		   _prima_neta
	  from emipocob
	 where no_poliza = a_no_poliza
	   and no_unidad = a_no_unidad

	let _cnt_cober = 0;

	--Verifica que la equivalencia de la cobertura exista en la tabla de equivalencias.
	select count(*)
	  into _cnt_cober
	  from prdequicober
	 where cod_cobertura = _cod_cobertura;

	if _cnt_cober > 0 then

		{select descuento_max, 
			   tipo_descuento
		  into _descuento_max, 
			   _tipo_descuento 
		  from prdcobpd
		 where cod_producto  = _cod_producto
		   and cod_cobertura = _cod_cobertura;

		let _porc_desc_rc = 0.00;
		let _porc_desc_tabla = 0.00;
		let _porc_desc_sinis = 0.00;
		let _desc_modelo = 0.00;

		if _tipo_descuento = 1 then
			let _porc_desc_rc = _descuento_max;
			let _porc_desc_tabla = 0.00;
			let _porc_desc_sinis = 0.00;
			let _desc_modelo = 0.00;
		elif _tipo_descuento = 2 then
			
			let _porc_desc_modelo = _desc_modelo;
			let _porc_desc_tabla = _desc_tabla;
			let _porc_desc_sinis = _desc_sinis
			let _porc_desc_rc = 0.00;
			
			update prdpreren
			   set porc_desc_rc = _porc_desc_rc,
				   porc_desc_tabla = _porc_desc_tabla,
				   porc_desc_modelo = _porc_desc_modelo,
				   porc_desc_sinis = _porc_desc_sinis
			 where no_documento = _no_documento
			   and no_unidad = a_no_unidad;
		end if}

		--Busca los campos a actualizar
		select campo_prima,
			   campo_limite,
			   campo_desc_limite,
			   campo_deducible
		  into _campo_prima,
			   _campo_limite,
			   _campo_desc_limite,
			   _campo_deducible
		  from prdequicober
		 where cod_cobertura = _cod_cobertura;

		let _sql_describe = "update prdpreren set " || trim(_campo_prima) || " = " || trim(_campo_prima) || ' + ' || cast(_prima_neta as varchar(10));

		if _campo_limite is not null then
			let _sql_describe = trim(_sql_describe) || ", " || trim(_campo_limite) || " = '" || cast(_limite1 as varchar(10)) || " - " || cast(_limite2 as varchar(10)) || "'";
		end if

		if _campo_desc_limite is not null then
			if _desc_limite1 is null then
				let _desc_limite1 = "";
			end if

			if _desc_limite2 is null then
				let _desc_limite2 = "";
			end if
			
			if _desc_limite1 <>  "" or _desc_limite2 <> "" then
				let _sql_describe = trim(_sql_describe) || ", " || trim(_campo_desc_limite) || " = '" || _desc_limite1 || " - " || _desc_limite2 || "'";				
			end if
		end if

		if _campo_deducible is not null then
			if _campo_deducible is null then
				let _campo_deducible = "";
			end if

			let _sql_describe = trim(_sql_describe) || ", " || trim(_campo_deducible) || " = '" || _deducible || "'";
		end if

		--Arma el where del update
		let _sql_where = "no_documento = '" || trim(_no_documento) || "' and no_unidad = '" || trim(a_no_unidad) || "';";

		--Une el update con el where para poder ser ejecutado
		let _sql_describe = trim(_sql_describe) || " where " || _sql_where;

		{prepare equisql from _sql_describe;	
		declare equicur cursor for equisql;
		open equicur;
		while (1 = 1)

			if (sqlcode = 100) then
				exit;
			end if

			if (sqlcode != 100) then

			else
				exit;
			end if
		end while
		close equicur;	
		free equicur;
		free equisql;}
		
		--Se Ejecuta el update.
		execute immediate _sql_describe;
	end if
end foreach

return 0,_sql_describe;

--drop table tmp_cober;
end
end procedure 