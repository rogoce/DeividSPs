
DROP PROCEDURE sp_re143;

CREATE PROCEDURE "informix".sp_re143()
RETURNING   CHAR(100),
		    DECIMAL(16,2),
			CHAR(10),
			CHAR(8),
			CHAR(8),
			DATE,
			CHAR(10),
			CHAR(10),
			CHAR(10);

DEFINE v_a_nombre_de  CHAR(50);     
DEFINE v_monto        DECIMAL(16,2);
DEFINE _no_requis     CHAR(10);
define _user_added    CHAR(8);
define _aut_workflow_user    CHAR(8);
define _fecha_captura date;
define _cod_cliente   char(10);
define _cod_cliente2  char(10);
define _transaccion   char(10);

set isolation to dirty read;

FOREACH 
	 SELECT a_nombre_de,
			monto,
			no_requis,
			user_added,
			aut_workflow_user,
			fecha_captura,
			cod_cliente
	   INTO v_a_nombre_de,
			v_monto,
			_no_requis,
			_user_added,
			_aut_workflow_user,
			_fecha_captura,
			_cod_cliente2
	   FROM chqchmae
	  WHERE cod_compania   = '001'
		AND autorizado     = 1
		AND pagado         = 1
		AND anulado        = 0
		AND cod_banco      = '001'
		AND cod_chequera   = '006'
		AND tipo_requis    = "C"

	 if _aut_workflow_user is null then
		let _aut_workflow_user = "";
	 end if
	-- Actualizacion para los Cheques de Reclamos

		FOREACH
			 SELECT cod_cliente,
			        transaccion
			   INTO _cod_cliente,
			        _transaccion
			   FROM rectrmae
			  WHERE no_requis = _no_requis

			IF _cod_cliente = _cod_cliente2 THEN
			else	
				RETURN  v_a_nombre_de,
						v_monto, 
						_no_requis,
						_user_added,
						_aut_workflow_user,
						_fecha_captura,
						_cod_cliente2,
						_cod_cliente,
						_transaccion
						with resume;
			end if

		END FOREACH
end foreach

END PROCEDURE;
