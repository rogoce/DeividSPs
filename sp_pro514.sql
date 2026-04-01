-- Procedimiento que el reporte de los colaterales
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro514;

create procedure "informix".sp_pro514(a_cod_cliente CHAR(255) DEFAULT "*")
returning char(3),
          char(50),
		  char(50),
		  dec(16,2),
		  char(10),
		  char(50),
		  char(255);

define v_filtros        char(255);
define _tipo          	char(1);

define _cod_cliente		char(10);
define _cod_tipogar		char(3);
define _desc_colateral	char(50);
define _monto			dec(16,2);

define _nombre_tipogar	char(50);
define _nombre_cliente	char(50);

create temp table tmp_colateral(
cod_tipogar		char(3),
nombre_tipogar	char(50),
desc_colateral	char(50),
monto			dec(16,2),
cod_cliente		char(10),
nombre_cliente	char(50),
seleccionado	smallint
) with no log;

set isolation to dirty read;

foreach
 select cod_cliente,
		cod_tipogar,
		desc_colateral,
		monto
   into	_cod_cliente,
		_cod_tipogar,
		_desc_colateral,
		_monto
   from clicolat
  where activo = 1

	select nombre
	  into _nombre_tipogar
	  from clitigar
	 where cod_tipogar = _cod_tipogar;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	insert into tmp_colateral
	values (_cod_tipogar, _nombre_tipogar, _desc_colateral, _monto, _cod_cliente, _nombre_cliente, 1);


end foreach

-- Filtros

let v_filtros = "";

if a_cod_cliente <> "*" then

	let v_filtros = TRIM(v_filtros) || " Cliente: " ||  TRIM(a_cod_cliente);

	let _tipo = sp_sis04(a_cod_cliente);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- Incluir los Registros

		update tmp_colateral
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_cliente not in (select codigo from tmp_codigos);

	else		        -- Excluir estos Registros

		update tmp_colateral
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_cliente in (select codigo from tmp_codigos);

	end if

	drop table tmp_codigos;

end if

foreach
 select cod_tipogar,
		nombre_tipogar,
		desc_colateral,
		monto,
		cod_cliente,
		nombre_cliente
   into _cod_tipogar,
		_nombre_tipogar,
		_desc_colateral,
		_monto,
		_cod_cliente,
		_nombre_cliente
   from tmp_colateral
  where seleccionado = 1

	return _cod_tipogar,
		   _nombre_tipogar,	
	       _desc_colateral,
		   _monto,
		   _cod_cliente,
		   _nombre_cliente,
		   v_filtros
		   with resume;

end foreach

drop table tmp_colateral;
 
end procedure
