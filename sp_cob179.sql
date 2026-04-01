drop procedure sp_cob179;

create procedure sp_cob179()
returning char(20),
          char(10),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2);

define _no_documento	char(20);
define _saldo1 			dec(16,2);
define _saldo2			dec(16,2);

define _monto			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_neta_cal	dec(16,2);
define _no_recibo		char(10);

define _no_remesa		char(10);
define _renglon			smallint;

foreach
 select no_documento, 
		saldo1, 
		saldo2
   into _no_documento, 
		_saldo1, 
		_saldo2
   from tmp_compsaldo
--  where no_documento = "0295-0638-01"

	if _saldo1 > _saldo2 then

		foreach
		 select no_recibo,
		        prima_neta,
		        impuesto,
		        monto,
				no_remesa,
				renglon
		   into _no_recibo,
		        _prima_neta,
		        _impuesto,
		        _monto,
		        _no_remesa,
		        _renglon    		
		   from cobredet
		  where doc_remesa = _no_documento
		    and actualizado = 1

			let _prima_neta_cal = _monto / 1.06;

			if _prima_neta <> _prima_neta_cal then
			
					{
					update cobredet
					   set prima_neta = impuesto,
					       impuesto   = 0
					 where no_remesa  = _no_remesa
					   and renglon    = _renglon;
					--}

				return _no_documento,
				       _no_recibo,
				       _monto,
				       _impuesto,
				       _prima_neta,
				       _prima_neta_cal,
				       (_prima_neta_cal - _prima_neta) 
			   			with resume;
	
			end if

		end foreach

	end if

end foreach

end procedure
