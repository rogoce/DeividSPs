
DROP procedure sp_jean03ab;
CREATE procedure sp_jean03ab(a_periodo char(7))
RETURNING char(10);

DEFINE _no_tranrec,_no_factura,_no_reclamo	 	CHAR(10);
DEFINE _no_documento    CHAR(20);
define _numrecla        char(18);
define _n_cobertura     char(50);
define _mto_archivo,_monto_cober           dec(16,2);
define _cod_cobertura char(5);
define _cod_cober_reas char(3);
define _periodo char(7);
define _cnt,_valor smallint;
define _mensaje varchar(250);
    

let _mto_archivo = 0.00;
let _monto_cober = 0.00;

foreach

	select no_reclamo
	  into _no_reclamo
      from deivid_tmp:sini_aud_tmp
     where periodo = a_periodo
	 
	select count(*)
      into _cnt
      from recreaco
     where no_reclamo = _no_reclamo
	   and porc_partic_prima = 5;
 
    if _cnt = 0 then
	    call sp_sis18(_no_reclamo) returning _valor,_mensaje;
		
		return _no_reclamo with resume;
	else
		foreach
			select no_tranrec
		      into _no_tranrec
		      from rectrmae
		     where no_reclamo = _no_reclamo
		       and actualizado = 1
		       and periodo = a_periodo
		       and cod_tipotran = '004'
			   
			call sp_sis58(_no_tranrec) returning _valor,_mensaje;
			
			return _no_tranrec with resume;
			  
		end foreach
	end if
	 
	{foreach
		select no_tranrec,numrecla
		  into _no_tranrec,_numrecla
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and actualizado = 1
		   and periodo = a_periodo
		   and cod_tipotran = '004'
	   	
		foreach
			select cod_cobertura,
				   monto
			  into _cod_cobertura,
				   _monto_cober
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and monto <> 0
			   
			if _monto_cober = _mto_archivo then
				select cod_cober_reas,
				       nombre
				  into _cod_cober_reas,
				       _n_cobertura
				  from prdcober
				 where cod_cobertura = _cod_cobertura;
				 
				if _cod_cober_reas in('045','046','047') then
					return _no_reclamo,_no_tranrec,_numrecla,_mto_archivo,_monto_cober,a_periodo,_n_cobertura with resume;
				else
					update deivid_tmp:sini_aud_tmp
					   set marcar = 1
					  where no_reclamo = _no_reclamo
                        and periodo    = a_periodo;
					
					return _no_reclamo,_no_tranrec,_numrecla,_mto_archivo,_monto_cober,'otro',_n_cobertura with resume;
				end if
			--else
				--return _no_reclamo,_no_tranrec,_numrecla,_mto_archivo,_monto_cober,'distinto' with resume;
			end if
		end foreach
	end foreach}
end foreach
END PROCEDURE;
