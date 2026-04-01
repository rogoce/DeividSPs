-- Procedimiento para la aplicacion de la nueva ley	de seguros

-- Creado    : 04/01/2013 - Autor: Amado Perez
drop procedure ap_legal;

create procedure ap_legal(a_no_poliza CHAR(10))
returning smallint,
          char(50);

define _error					int;
define _error_isam				int;
define _prima_bruta         	dec(16,2);
define _no_documento			char(20);
define _no_factura				char(10);
define _error_desc				char(50);
define _periodo                 char(7);
define _fecha       			date;
define _cod_compania, _cod_sucursal	char(3);
define v_saldo                  dec(16,2);
define _user_added 				char(8);
define _no_endoso               char(5);
define _cod_endomov				char(3);
define _cod_tipocalc			char(3);
define _tipo_mov                smallint;
define _no_poliza               char(10);
define _cod_abogado             char(3);
define _cod_formapag        	char(3);

--set debug file to "sp_pro517.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _fecha = current;

FOREACH
	select no_poliza,
		   cod_abogado
	  into _no_poliza,
		   _cod_abogado
	  from tmpoutleg
	 where generar_endoso = 1
	   and gen_endcan = 0
	   and no_poliza = a_no_poliza

    let _no_endoso = null;

    foreach
		select no_endoso
		  into _no_endoso
		  from endedmae
		 where no_poliza = _no_poliza
		   and cod_endomov = '002'
		   and cod_tipocalc = '001'
	  order by no_endoso Desc
	end foreach

    if _no_endoso is null then
		continue foreach;
	end if

	select no_documento,
	       no_factura,
		   periodo,
		   user_added,
		   cod_endomov,
		   cod_tipocalc,
		   cod_sucursal
	  into _no_documento,
	       _no_factura,
		   _periodo,
		   _user_added,
		   _cod_endomov,
		   _cod_tipocalc,
		   _cod_sucursal
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	SELECT tipo_mov INTO _tipo_mov FROM endtimov WHERE cod_endomov = _cod_endomov;

	If _tipo_mov <> 2 Or _cod_tipocalc <> "001" Then
		Return 0, "No es cancelacion a prorrata";
	End If

	SELECT cod_compania, cod_formapag
	  INTO _cod_compania, _cod_formapag
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	CALL sp_cob115b(
	_cod_compania,
	"",
	_no_documento,
	""
	) RETURNING v_saldo;

	set lock mode to wait;

	-- Insertando en la tabla cobranza externa

	delete from coboutleg where no_documento = _no_documento;

	insert into coboutleg(
	no_documento,
	fecha,
	no_factura,
	no_poliza,
	prima,
	pagos,
	saldo,
	cod_abogado
	)
	values(
	_no_documento, 
	_fecha,
	_no_factura,
	_no_poliza,
	v_saldo,
	0,
	v_saldo,
    _cod_abogado
	);

	set isolation to dirty read;

	-- Creacion del endoso de cancelacion por saldo
		CALL sp_pro518(
		_no_poliza,
		_user_added,
		v_saldo,
		_cod_sucursal
		) RETURNING _error,
				    _error_desc,
				    _no_endoso;

		if _error <> 0 then
			return _error, _error_desc;
		end if

	-- Insertando cambio de plan de pago

       IF _cod_formapag <> "087" THEN

			CALL sp_pro519(
			_no_poliza,
			_user_added,
			v_saldo,
			_cod_compania,
			_cod_sucursal,
			_cod_formapag
			) RETURNING _error,
					    _error_desc;

			if _error <> 0 then
				return _error, _error_desc;
			end if

		END IF

        UPDATE tmpoutleg
		   SET gen_endcan = 1
		 WHERE no_poliza = _no_poliza; 


END FOREACH

end

return 0,'aplicacion de nueva ley exitoso';

end procedure


