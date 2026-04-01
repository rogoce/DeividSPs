drop procedure sp_bo038;
 
create procedure "informix".sp_bo038()
returning char(20),
          dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _no_poliza		char(10);
define _no_documento	char(20);
define _cod_contrato	char(5);
define _porc_partic		dec(16,2);
define _tipo_contrato	smallint;
define _saldo_pxc		dec(16,2);
define _pxc_retencion	dec(16,2);
define _periodo         char(7);

set isolation to dirty read;

let _periodo = "2006-12";

foreach
 select	no_documento,
        saldo_pxc,
		no_poliza
   into	_no_documento,
        _saldo_pxc,
		_no_poliza
   from deivid_cob:cobmoros
  where periodo = _periodo

    let _porc_partic = 0.00;

	foreach
	 select cod_contrato,
	        porc_partic_suma
	   into _cod_contrato,
	        _porc_partic
	   from	emifacon
	  where no_poliza = _no_poliza
	    and no_endoso = "00000"

		select tipo_contrato
		  into _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _tipo_contrato = 1 then
			exit foreach;
		end if
		
	end foreach

	let _pxc_retencion = _saldo_pxc * _porc_partic / 100;	

	update deivid_cob:cobmoros
	   set saldos_neto_impuesto = _pxc_retencion,
	       subir_bo             = 1
	 where no_documento         = _no_documento
	   and periodo              = _periodo;

	return _no_documento,
	       _saldo_pxc,
		   _pxc_retencion,
		   _porc_partic
		   with resume;

end foreach

end procedure