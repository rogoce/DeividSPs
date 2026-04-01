-- Procedimiento que carga de talle de comprobante en SAC proveniente de un archivo de excel
-- 
-- Creado    : 25/07/2025 - Autor: Armando Moreno

DROP PROCEDURE sp_sac_cargar_detalle;
CREATE PROCEDURE sp_sac_cargar_detalle(a_no_trx integer)
RETURNING INTEGER,CHAR(50);

DEFINE _error_code      INTEGER;

DEFINE _linea,_linea3,_linea_trx2  	INTEGER;  
DEFINE _trx1_tipo    	CHAR(2); 
DEFINE _cod_compania	CHAR(3);
DEFINE _cod_sucursal	CHAR(3);
define _trx1_ccosto     char(3);
DEFINE _tipo_mov        CHAR(1);
DEFINE _cuenta 	        CHAR(12);
DEFINE _descripcion   	CHAR(100);
DEFINE _debito,_credito,_db_trx2,_cr_trx2 dec(16,2);
define _aux             char(5);
define _cnt             smallint;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Cargar detalle de comprobante';         
END EXCEPTION           

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_sac_cargar_detalle.trc";
--trace on;


delete from cgltrx3
where trx3_notrx = a_no_trx
  and trx3_actlzdo = 0;

delete from cgltrx2
where trx2_notrx = a_no_trx
  and trx2_actlzdo = 0;

select trx1_tipo,
       trx1_ccosto
  into _trx1_tipo,
       _trx1_ccosto
  from cgltrx1
 where trx1_notrx = a_no_trx;

let _aux = null;
FOREACH
	SELECT linea,
	       cuenta,
	       debito,
		   credito,
		   aux
	  INTO _linea,
		   _cuenta,
		   _debito,
		   _credito,
		   _aux
	  FROM comprobante_arch
	  
	select count(*)
	  into _cnt
	  from cgltrx2
	 where trx2_notrx = a_no_trx
	   and trx2_linea = _linea;
	   
	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt > 0 then
		continue foreach;
	end if
	  
	if _aux is null then
		INSERT INTO cgltrx2(
		trx2_notrx,
		trx2_tipo,
		trx2_linea,
		trx2_cuenta,
		trx2_ccosto,
		trx2_debito,
		trx2_credito,
		trx2_actlzdo
		)
		VALUES(
		a_no_trx,
		_trx1_tipo,
		_linea,
		_cuenta,
		_trx1_ccosto,
		_debito,
		_credito,
		0
		);
	else
		foreach
			select linea,
			       cuenta,
				   sum(debito),
				   sum(credito)
			  into _linea_trx2,
                   _cuenta,
				   _db_trx2,
				   _cr_trx2
              from comprobante_arch
             where linea = _linea
          group by linea,cuenta
		  
			INSERT INTO cgltrx2(
			trx2_notrx,
			trx2_tipo,
			trx2_linea,
			trx2_cuenta,
			trx2_ccosto,
			trx2_debito,
			trx2_credito,
			trx2_actlzdo
			)
			VALUES(
			a_no_trx,
			_trx1_tipo,
			_linea_trx2,
			_cuenta,
			_trx1_ccosto,
			_db_trx2,
			_cr_trx2,
			0
			);
		  
			let _linea3 = 0;
			foreach
				select linea,
					   cuenta,
					   debito,
					   credito,
					   aux
				  into _linea,
					   _cuenta,
					   _debito,
					   _credito,
					   _aux
				  from comprobante_arch
				 where linea = _linea
				 
				let _linea3 = _linea3 + 1;
				
				INSERT INTO cgltrx3(
				trx3_notrx,
				trx3_tipo,
				trx3_lineatrx2,
				trx3_linea,
				trx3_cuenta,
				trx3_auxiliar,
				trx3_debito,
				trx3_credito,
				trx3_actlzdo,
				trx3_referencia
				)
				VALUES(
				a_no_trx,
				_trx1_tipo,
				_linea,
				_linea3,
				_cuenta,
				_aux,
				_debito,
				_credito,
				0,
				''
				);
			end foreach
		end foreach
	end if
END FOREACH

RETURN 0, "Actualizacion Exitosa...";

END

END PROCEDURE;
