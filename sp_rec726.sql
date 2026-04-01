-- Procedimiento para generacion de requisicion para proceso de ajuste de ordenes de compra/reparacion
-- 
-- creado: 09/10/2014 - Autor: Armando Moreno

DROP PROCEDURE sp_rec726;
CREATE PROCEDURE "informix".sp_rec726(a_no_ajuste CHAR(5), a_cod_proveedor char(10)) 
RETURNING SMALLINT, CHAR(50), SMALLINT;  

DEFINE _no_reclamo			CHAR(10);
DEFINE _cod_compania		CHAR(3);
DEFINE _cod_sucursal		CHAR(3);
DEFINE _fecha				DATE;
DEFINE _transaccion			CHAR(10);
DEFINE _periodo			    CHAR(7);
DEFINE _cod_cliente			CHAR(10);
DEFINE _cod_tipotran        CHAR(3);
DEFINE _cod_tipopago		CHAR(3);
DEFINE _no_requis			CHAR(10);
DEFINE _monto				DEC(16,2);
DEFINE _user_added			CHAR(8);
DEFINE _nombre			    VARCHAR(100);  
DEFINE _acreedor		    VARCHAR(100);  
DEFINE _no_requis_n			CHAR(10);
DEFINE _cod_banco		    CHAR(3);
DEFINE _cod_chequera		CHAR(3);
DEFINE _no_poliza			CHAR(10);
DEFINE _cod_ramo			CHAR(3);
DEFINE _ramo_sis            SMALLINT;
DEFINE _cod_ruta			CHAR(2);
DEFINE _wf_pedir_rec        SMALLINT;
DEFINE _genera_incidente    SMALLINT;
DEFINE _numrecla            CHAR(18);
DEFINE _desc_nota           VARCHAR(250);
DEFINE _des_renglon1      	VARCHAR(100);
DEFINE _filas               SMALLINT;
DEFINE _firma_electronica  	SMALLINT;
DEFINE _autorizado  	    SMALLINT;
DEFINE _en_firma            SMALLINT;

DEFINE _fecha_captura       DATE;
DEFINE _nombre_cheq         CHAR(100);
DEFINE _monto_cheq          DEC(16,2);

DEFINE _error   			INTEGER;
define _tipo_requis         char(1);
define _agrega_acreedor     smallint;
define _periodo_pago        smallint;
DEFINE _no_orden            CHAR(10);
define _no_tranrec          CHAR(10);
define a_fecha              datetime hour to fraction(5);
define _no_tranrec_neg      char(10);
define _no_tranrec_pre      char(10);
define _error_isam          integer;
define _error_desc			char(50);
define _tipo_opc            smallint;
define _estado_cta          varchar(10);


LET _no_requis   = NULL;
LET _autorizado  = 0;
LET _en_firma    = 0;
LET _no_requis_n = NULL;
LET _tipo_requis = "C";


SET ISOLATION TO DIRTY READ;

if a_no_ajuste = '07230' then
  set debug file to "sp_rec726.trc";
  trace on;
end if

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, 0;
end exception

let _cod_compania = '001';
let _cod_sucursal = '001';
let _cod_cliente  = a_cod_proveedor;
let _fecha        = current;
let _periodo      = sp_sis39(_fecha);
let _no_tranrec_neg = null;
let _no_tranrec_pre	= null;

let a_fecha = current;

SELECT nombre,
       cod_ruta,
       periodo_pago
  INTO _nombre,
       _cod_ruta,
       _periodo_pago
  FROM cliclien
 WHERE cod_cliente = _cod_cliente;

select user_added, 
       estado_cta
  into _user_added,
       _estado_cta
  from recordam
 where no_ajus_orden = a_no_ajuste;
 
if _estado_cta is null then
	let _estado_cta = "";
end if

let _ramo_sis = 1;

LET _genera_incidente = 1;
LET _no_requis_n = sp_sis71(_cod_compania);

IF _no_requis_n IS NULL OR _no_requis_n = "" OR _no_requis_n = "00000" THEN
    RETURN 1, "Error al generar requisicion, verifique...", 0;
END IF

LET _no_requis = _no_requis_n;

	let _cod_banco    = '001';
	let _cod_chequera = '001';

LET _tipo_requis = "C";


LET _cod_ruta     = NULL;
LET _wf_pedir_rec = NULL;


IF _ramo_sis = 1 THEN
    SELECT firma_electronica
	  INTO _firma_electronica
	  FROM chqchequ
	 WHERE cod_banco    = _cod_banco
	   AND cod_chequera = _cod_chequera;

    IF _firma_electronica = 1 THEN
		LET _autorizado       = 1;
		LET _en_firma         = 4;
		LET _genera_incidente = 0;
	END IF

END IF

SET LOCK MODE TO WAIT 60;

BEGIN
		ON EXCEPTION SET _error 

		 	RETURN _error, "Error al actualizar REQUISICION", 0;         
		END EXCEPTION 
		INSERT INTO chqchmae(
		no_requis,
		monto,
		pagado,
		anulado,
		periodo,
		cobrado,
		cuenta,
		cod_cliente,
		autorizado,
		cod_agente,
		a_nombre_de,
		user_added,
		anulado_por,
		cod_banco,
		cod_chequera,
		cod_compania,
		cod_sucursal,
		no_cheque,
		fecha_cobrado,
		fecha_anulado,
		origen_cheque,
		fecha_captura,
		autorizado_por,
		fecha_impresion,
		cod_ruta,
		wf_pedir_rec,
		en_firma,
		tipo_requis,
		periodo_pago
		)
		VALUES(
		_no_requis_n,
		0,
		0,
		0,
		_periodo,
		0,
		null,
		_cod_cliente,
		_autorizado,
		null,
		_nombre,
		_user_added,
		null,
		_cod_banco,
		_cod_chequera,
		_cod_compania,
		_cod_sucursal,
		0,
		null,
		null,
		3,
		current,
		null,
		current,
		_cod_ruta,
		_wf_pedir_rec,
		_en_firma,
		_tipo_requis,
		_periodo_pago
		);
END

-- Descripcion del Cheque
insert into chqchdes(
no_requis,
renglon,
desc_cheque
)
values(
_no_requis,
1,
'PARA PAGAR FACTURAS CORRESPONDIENTES A '|| UPPER(TRIM(_estado_cta))
);

--INSERCION EN CHQCHREC CON LAS TRANSACCIONES POR DIFERENCIA DE PRECIO YA SEA MAYOR O MENOR DE TODAS LAS ORDENES DEL AJUSTE
foreach	 
		select no_tranrec_pre
		  into _no_tranrec_pre
		  from recordad
		 where no_ajus_orden  = a_no_ajuste
		   and no_tranrec_pre is not null
		   and tipo_opc = 0

		let _transaccion = null;

	   	select transaccion
		  into _transaccion
		  from rectrmae
		 where actualizado = 1
		   and no_tranrec  = _no_tranrec_pre;

		 SELECT no_reclamo,
		        cod_compania,
				cod_sucursal,
				fecha,
				transaccion,
				periodo,
				cod_cliente,
				cod_tipotran,
				cod_tipopago,
				monto,
				user_added,
				numrecla,
				no_tranrec
		   INTO _no_reclamo,
		        _cod_compania,
				_cod_sucursal,
				_fecha,
				_transaccion,
				_periodo,
				_cod_cliente,
				_cod_tipotran,
				_cod_tipopago,
				_monto,
				_user_added,
				_numrecla,
				_no_tranrec
		   FROM rectrmae
		  WHERE transaccion = _transaccion;

     BEGIN
		ON EXCEPTION SET _error 
		 	RETURN _error, "Error al actualizar CHQCHREC X DIF " || _transaccion, 0;         
		END EXCEPTION 
		INSERT INTO chqchrec(
		no_requis,
		transaccion,
		monto,
		numrecla
		) 
		VALUES(
		_no_requis_n,
		_transaccion,
		_monto,
		_numrecla
		);
	 END

     BEGIN
		ON EXCEPTION SET _error 
		 	RETURN _error, "Error al actualizar descripcion de la requisicion", 0;         
		END EXCEPTION 
		UPDATE rectrmae
		   SET no_requis  = _no_requis_n,
		       generar_cheque = 1
		 WHERE no_tranrec = _no_tranrec;   
	 END

end foreach

--INSERCION EN CHQCHREC CON LAS TRANSACCIONES NEGATIVAS DE TODAS LAS ORDENES DEL AJUSTE
foreach	 
		select no_tranrec_neg
		  into _no_tranrec_neg
		  from recordad
		 where no_ajus_orden  = a_no_ajuste
		   and no_tranrec_neg is not null
		   and tipo_opc in(0,6)

		let _transaccion = null;

	   	select transaccion
		  into _transaccion
		  from rectrmae
		 where actualizado = 1
		   and no_tranrec  = _no_tranrec_neg;

		 SELECT no_reclamo,
		        cod_compania,
				cod_sucursal,
				fecha,
				transaccion,
				periodo,
				cod_cliente,
				cod_tipotran,
				cod_tipopago,
				monto,
				user_added,
				numrecla,
				no_tranrec
		   INTO _no_reclamo,
		        _cod_compania,
				_cod_sucursal,
				_fecha,
				_transaccion,
				_periodo,
				_cod_cliente,
				_cod_tipotran,
				_cod_tipopago,
				_monto,
				_user_added,
				_numrecla,
				_no_tranrec
		   FROM rectrmae
		  WHERE transaccion = _transaccion;

     BEGIN
		ON EXCEPTION SET _error 
		 	RETURN _error, "Error al actualizar CHQCHREC NEG " || _transaccion, 0;         
		END EXCEPTION 
		INSERT INTO chqchrec(
		no_requis,
		transaccion,
		monto,
		numrecla
		) 
		VALUES(
		_no_requis_n,
		_transaccion,
		_monto,
		_numrecla
		);
	 END

     BEGIN
		ON EXCEPTION SET _error 
		 	RETURN _error, "Error al actualizar descripcion de la requisicion", 0;         
		END EXCEPTION 
		UPDATE rectrmae
		   SET no_requis  = _no_requis_n,
		       generar_cheque = 1
		 WHERE no_tranrec = _no_tranrec;   
	 END

end foreach

--INSERCION EN CHQCHREC CON LAS TRANSACCIONES ORIGINALES DE TODAS LAS ORDENES DEL AJUSTE
foreach	 
		select no_orden,
		       transaccion_alq,
		       tipo_opc
		  into _no_orden,
		       _transaccion,
		       _tipo_opc
		  from recordad
		 where no_ajus_orden = a_no_ajuste
		   and tipo_opc      in(0,6)

		if _tipo_opc = 0 then
			let _transaccion = null;

		   	select trans_pend
			  into _transaccion
			  from recordma
			 where no_orden = _no_orden;

	        if _transaccion is null then
				select transaccion
				  into _transaccion
				  from recordma
				 where no_orden = _no_orden;
			end if
		end if

		SELECT no_reclamo,
		       cod_compania,
			   cod_sucursal,
			   fecha,
			   transaccion,
			   periodo,
			   cod_cliente,
			   cod_tipotran,
			   cod_tipopago,
			   monto,
			   user_added,
			   numrecla,
			   no_tranrec
		  INTO _no_reclamo,
		       _cod_compania,
			   _cod_sucursal,
			   _fecha,
			   _transaccion,
			   _periodo,
			   _cod_cliente,
			   _cod_tipotran,
			   _cod_tipopago,
			   _monto,
			   _user_added,
			   _numrecla,
			   _no_tranrec
		  FROM rectrmae
		 WHERE transaccion = _transaccion;

     BEGIN
		ON EXCEPTION SET _error 
		 	RETURN _error, "Error al actualizar CHQCHREC ORIG " || _transaccion, 0;         
		END EXCEPTION 
		INSERT INTO chqchrec(
		no_requis,
		transaccion,
		monto,
		numrecla
		) 
		VALUES(
		_no_requis_n,
		_transaccion,
		_monto,
		_numrecla
		);
	 END

     BEGIN
		ON EXCEPTION SET _error 
		 	RETURN _error, "Error al actualizar descripcion de la requisicion", 0;         
		END EXCEPTION 
		UPDATE rectrmae
		   SET no_requis  = _no_requis_n,
		       generar_cheque = 1
		 WHERE no_tranrec = _no_tranrec;   
	 END
end foreach

--INSERCION EN CHQCHREC CON LAS TRANSACCIONES POR ALINEAMIENTO, FLETE, DEDUCIBLES
foreach	 
		select no_tranrec_pre
		  into _no_tranrec_pre
		  from recordad
		 where no_ajus_orden  = a_no_ajuste
		   and no_tranrec_pre is not null
		   and tipo_opc <> 0

		let _transaccion = null;

	   	select transaccion
		  into _transaccion
		  from rectrmae
		 where actualizado = 1
		   and no_tranrec  = _no_tranrec_pre;

		 SELECT no_reclamo,
		        cod_compania,
				cod_sucursal,
				fecha,
				transaccion,
				periodo,
				cod_cliente,
				cod_tipotran,
				cod_tipopago,
				monto,
				user_added,
				numrecla,
				no_tranrec
		   INTO _no_reclamo,
		        _cod_compania,
				_cod_sucursal,
				_fecha,
				_transaccion,
				_periodo,
				_cod_cliente,
				_cod_tipotran,
				_cod_tipopago,
				_monto,
				_user_added,
				_numrecla,
				_no_tranrec
		   FROM rectrmae
		  WHERE transaccion = _transaccion;

     BEGIN
		ON EXCEPTION SET _error 
		 	RETURN _error, "Error al actualizar CHQCHREC A,F,D " || _transaccion, 0;         
		END EXCEPTION 
		INSERT INTO chqchrec(
		no_requis,
		transaccion,
		monto,
		numrecla
		) 
		VALUES(
		_no_requis_n,
		_transaccion,
		_monto,
		_numrecla
		);
	 END

     BEGIN
		ON EXCEPTION SET _error 
		 	RETURN _error, "Error al actualizar descripcion de la requisicion", 0;         
		END EXCEPTION 
		UPDATE rectrmae
		   SET no_requis  = _no_requis_n,
		       generar_cheque = 1
		 WHERE no_tranrec = _no_tranrec;   
	 END

end foreach

--INSERCION EN RECNOTAS POR RECLAMO

foreach
	select transaccion
	  into _transaccion
	  from chqchrec
	 where no_requis = _no_requis_n

    select cod_tipopago,
	       no_reclamo,
		   user_added
	  into _cod_tipopago,
	       _no_reclamo,
		   _user_added
	  from rectrmae
	 where transaccion = _transaccion;  

	 IF _cod_tipopago = "001" THEN
	 	LET _desc_nota = "Requisicion emitida # " || trim(_no_requis_n) || " para pago al Proveedor " || trim(_nombre) || ", transaccion # " || _transaccion;
	 ELIF _cod_tipopago = "002" THEN
	 	LET _desc_nota = "Requisicion emitida # " || trim(_no_requis_n) || " para el Taller " || trim(_nombre) || ", transaccion # " || _transaccion;
	 ELIF _cod_tipopago = "003" THEN
	 	LET _desc_nota = "Requisicion emitida # " || trim(_no_requis_n) || " para el Asegurado " || trim(_nombre) || ", transaccion # " || _transaccion;
	 ELSE
	 	LET _desc_nota = "Requisicion emitida # " || trim(_no_requis_n) || " para el Tercero " || trim(_nombre) || ", transaccion # " || _transaccion;
	 END IF

	 let a_fecha = a_fecha + 5 units second;

	 BEGIN
		ON EXCEPTION SET _error 
		 	RETURN _error, "Error al insertar RECNOTAS", 0;         
		END EXCEPTION 
		INSERT INTO recnotas(
		no_reclamo,
		fecha_nota,
		desc_nota,
		user_added
		) 
		VALUES(
		_no_reclamo,
		a_fecha,
	    _desc_nota,
		_user_added
		);
	 END
	 SET ISOLATION TO DIRTY READ;
end foreach

select sum(monto)
  into _monto
  from chqchrec
 where no_requis = _no_requis;

update chqchmae
   set monto     = _monto
 where no_requis = _no_requis;

update recordam
   set no_requis     = _no_requis
 where no_ajus_orden = a_no_ajuste;

 
RETURN 0, "Actualizacion Exitosa", _genera_incidente;

end
END PROCEDURE