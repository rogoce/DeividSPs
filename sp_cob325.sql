-- Verificando si estas polizas de la remesa estan canceladas por falta de pago para realizar el movimiento de Devolucion por Cancelacion Poliza "K"

-- Creado por: Amado Perez M - 18/03/2013

drop procedure sp_cob325;

create procedure sp_cob325(a_no_remesa char(10))
returning integer,
          char(100);

define _e_mail_corredor		varchar(50);
define _e_mail				varchar(50);
define _desc_error			char(100); 
define _doc_remesa			char(20);
define _cod_contratante		char(10);
define _cob_no_devleg		char(10);
define _no_requis			char(10);
define _no_poliza			char(10);
define _no_recibo			char(10);
define _cod_formapag		char(3);
define _cod_tipocan			char(3);
define _monto_descontado	dec(16,2);
define _prima_neta			dec(16,2);
define _saldo				dec(16,2);
define _monto				dec(16,2);
define _estatus_poliza		smallint;
define _comis_desc			smallint;
define _renglon_rem			integer;
define _cant				integer;
define _error				integer;
define _fecha				date;

--set debug file to "sp_cob325.trc";      
--trace on;


begin
on exception set _error
	return _error, "Error Actualizando Pago Cobranza Externa";
end exception

let _no_requis = null;

foreach
	select doc_remesa,
	       no_poliza,
		   no_recibo,
		   renglon,
		   monto,
		   fecha,
		   comis_desc,
		   monto_descontado
	  into _doc_remesa,
	       _no_poliza,
		   _no_recibo,
	       _renglon_rem,
		   _monto,
		   _fecha,
		   _comis_desc,
		   _monto_descontado
	  from cobredet
	 where no_remesa = a_no_remesa
	   and tipo_mov  = "P"

    let _cant = 0;

    select count(*)
	  into _cant
	  from coboutleg
	 where no_documento = _doc_remesa;
	 
	if _cant = 1 then
		continue foreach;
	end if

    let _cant = 0;

	-- Falta verificar si la poliza esta cancelada.

    select estatus_poliza,
		   cod_formapag
	  into _estatus_poliza,
		   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;

    if _estatus_poliza <> 2 then
		continue foreach;
	end if

	foreach
		select cod_tipocan
		  into _cod_tipocan
		  from endedmae
		 where no_poliza = _no_poliza
		   and cod_endomov = "002"
		 order by no_endoso desc

	    exit foreach;
	end foreach

	if _cod_tipocan = "001" and _cod_formapag = '087' then
		let _cant = 1;
	end if

 {	select count(*)
	  into _cant
	  from endedmae
	 where no_poliza = _no_poliza
	   and cod_endomov = '002'
	   and cod_tipocan = '001';
  }
	if _cant = 0 then
		continue foreach;
	end if

    -- Si tiene comision descontada se le resta del monto

    if _comis_desc = 1 then	
		let _monto = _monto - _monto_descontado;
	end if

	-- Proceso de Cambios

	 SELECT cod_contratante
	   INTO _cod_contratante
	   FROM emipomae
	  WHERE no_poliza = _no_poliza;

     select e_mail
	   into _e_mail
	   from cliclien
	  where cod_cliente = _cod_contratante;
   
    -- Generar requisicion
	
	let _e_mail_corredor = null;

    call sp_che138(a_no_remesa, _renglon_rem) returning _error, _desc_error, _no_requis, _e_mail_corredor;
    
    if _error <> 0 then
	   return _error, _desc_error;
    end if 

    if _e_mail_corredor is not null then
		let _e_mail = _e_mail_corredor;	
	end if

 	-- Insertar en la tabla cobdevleg

	let _cob_no_devleg = sp_sis13('001', 'COB', '02', 'cob_no_devleg');

    insert into cobdevleg(
	  no_devleg,
	  no_documento,
	  no_poliza,
	  monto,
	  e_mail,
	  cod_asegurado,
	  fecha_pago,
	  no_recibo,
	  no_requis,
	  no_remesa)
	values (
	  _cob_no_devleg,
	  _doc_remesa,
	  _no_poliza,
	  _monto,
	  _e_mail,
	  _cod_contratante,
	  _fecha,
	  _no_recibo,
	  _no_requis,
	  a_no_remesa
      );

	 update cobredet
	    set tipo_mov   = "K",
		    monto      = _monto,
		    prima_neta = _monto,
			impuesto   = 0.00,
			comis_desc = 0,
			monto_descontado = 0.00
	  where no_remesa = a_no_remesa
	    and renglon = _renglon_rem;

     delete from cobreagt 
	  where no_remesa = a_no_remesa
	    and renglon = _renglon_rem;

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure