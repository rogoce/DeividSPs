-- Polizas con Recibos sin Remesas
-- Modificado: 7/11/2002 - Amado Perez - Se buscan solo las polizas nuevas y se excluyen las cancelaciones
-- SIS v.2.0 - d_cobr_sp_cob72_dw1 - DEIVID, S.A.

--drop procedure sp_cob72;

create procedure sp_cob72(
a_compania char(3),
a_sucursal char(3)
)
returning char(20),
		  date,
		  date,	
          char(100),
		  char(10),
		  date,
		  char(1),
		  char(50);

define _no_poliza		char(10);
define _no_recibo		char(10);
define _no_documento	char(20);
define _vigencia_inic	date;
define _vigencia_final,_fecha_cancelacion	date;
define _cod_contratante	char(10);
define _fecha_suscrip	date;
define _actualizado		smallint;

define _nombre			char(100);
define _estatus 	char(1);
define v_nombre_cia		char(50);
define _estatus_poliza smallint;
set isolation to dirty read;

LET  v_nombre_cia = sp_sis01(a_compania); 

foreach
 select no_poliza,
        no_recibo,
		no_documento,
		vigencia_inic,
		vigencia_final,
		cod_contratante,
		fecha_suscripcion,
		fecha_cancelacion,
		estatus_poliza
   into	_no_poliza,
        _no_recibo,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_cod_contratante,
		_fecha_suscrip,
		_fecha_cancelacion,
		_estatus_poliza
   from emipomae
  where actualizado = 1
    and no_recibo   is not null
	and nueva_renov = 'N'

   let _actualizado = null;

   foreach
	select actualizado
	  into _actualizado
	  from cobredet
	 where no_poliza = _no_poliza
	   and no_recibo = _no_recibo
		exit foreach;
	end foreach

	let _estatus = NULL;

	if _actualizado is null then
		let _estatus = 1;
	elif _actualizado = 0 then
		let _estatus = 2;
	else				
		let _estatus = 3;
	end if

	if _estatus <> 3 then

		IF _estatus_poliza = 2 THEN --cancelada
			LET _vigencia_final = _fecha_cancelacion;
		END IF

		IF _estatus_poliza <> 2 THEN

			select nombre
			  into _nombre
			  from cliclien
			 where cod_cliente = _cod_contratante;

			return _no_documento,
				   _vigencia_inic,
				   _vigencia_final,
				   _nombre,
				   _no_recibo,
				   _fecha_suscrip,
				   _estatus,
				   v_nombre_cia
				   with resume;
		END IF

	end if

end foreach

end procedure;