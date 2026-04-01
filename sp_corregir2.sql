-- Procedure que determina cuales facturas han cambiado
-- desde que se crearon

-- Creado    : 31/07/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/07/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_corregir2;

create procedure sp_corregir2()
returning char(20),char(10),smallint,dec(16,2),dec(16,2),dec(16,2),char(8);

define _no_poliza		char(10);
define _cnt 			smallint;
define _no_documento    char(20);
define _ano             integer;
define _no_poliza_ult	char(10);
define _cod_formapag    char(3);
define _tipo_forma      smallint;
define _diezporc        dec(16,2);
define _saldo           dec(16,2);
define _porcentaje      integer;
define _prima_bruta     dec(16,2);
define _usu_cob         char(8);
define _estatus         smallint;
define _usuario         char(8);
define _cod_sucursal    char(3);
define _renglon         smallint;

set isolation to dirty read;

let _cnt = 0;

foreach

	select no_poliza,
	       no_documento,
		   estatus,
		   cod_sucursal
	  into _no_poliza,
	       _no_documento,
		   _estatus,
		   _cod_sucursal
	  from emirepo
	 where estatus NOT IN (1,5,9)
	   and saldo > 0
	   order by no_documento

    select cod_formapag,prima_bruta
	  into _cod_formapag,_prima_bruta
	  from emipomae
	 where no_poliza = _no_poliza;

	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	let _diezporc = 0;
	let _saldo    = 0;
	let _saldo = sp_cob115b('001','001',_no_documento,'');

	if _tipo_forma = 2 or _tipo_forma = 3 or _tipo_forma = 4 then	--2=visa,3=desc salario,4=ach

		select usuario_cobros,
		       saldo_elect
		  into _usu_cob,
		       _porcentaje
		  from emirepar;

	else
		
		select usuario_cobros,
		       saldo_porc
		  into _usu_cob,
		       _porcentaje
		  from emirepar;

	end if

	let _diezporc = _prima_bruta * (_porcentaje / 100);
    let _usu_cob = trim(_usu_cob);

	if _saldo > _diezporc then

	else

		select count(*)
		  into _cnt
		  from emideren
		 where no_poliza = _no_poliza;

		if _cnt > 0 then

			let _usuario = sp_pro331a(_no_poliza);

			if _cnt = 1 then

				select renglon
				  into _renglon
				  from emideren
				 where no_poliza = _no_poliza;

				if _renglon = 11 then

				  { 	 Update emirepo
						Set saldo       = _saldo,
						    user_cobros = null,
							user_added  = 'AUTOMATI',
							estatus     = 1
					  Where no_poliza   = _no_poliza;

					 delete from emideren
					  where no_poliza = _no_poliza;

			       RETURN  _no_documento,
			       		   _no_poliza,
						   0,
						   _saldo,
						   _diezporc,
						   _prima_bruta,
						   _usuario
			               WITH RESUME;	}
				 else
					 continue foreach;
				 end if

			else

			  	update emideren
				   set activo = 1
				 where no_poliza = _no_poliza
				   and renglon   = 11;

			   	 Update emirepo
					Set saldo       = _saldo,
					    user_cobros = null,
						user_added  = _usuario,
						estatus     = 2
				  Where no_poliza   = _no_poliza;

			       RETURN  _no_documento,
			       		   _no_poliza,
						   0,
						   _saldo,
						   _diezporc,
						   _prima_bruta,
						   _usuario
			               WITH RESUME;

			end if


		end if
	end if

end foreach



{foreach

	select no_poliza,
	       no_documento,
		   estatus
	  into _no_poliza,
	       _no_documento,
		   _estatus
	  from emirepo
	 where user_added = 'AUTOMATI'
	   and estatus <> 5

    select cod_formapag,prima_bruta
	  into _cod_formapag,_prima_bruta
	  from emipomae
	 where no_poliza = _no_poliza;

	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	let _diezporc = 0;
	let _saldo    = 0;
	let _saldo = sp_cob115b('001','001',_no_documento,'');

	if _tipo_forma = 2 or _tipo_forma = 3 or _tipo_forma = 4 then	--2=visa,3=desc salario,4=ach

		select usuario_cobros,
		       saldo_elect
		  into _usu_cob,
		       _porcentaje
		  from emirepar;

	else
		
		select usuario_cobros,
		       saldo_porc
		  into _usu_cob,
		       _porcentaje
		  from emirepar;

	end if

	let _diezporc = _prima_bruta * (_porcentaje / 100);
    let _usu_cob = trim(_usu_cob);

	if _saldo > _diezporc then

       RETURN  _no_documento,
       		   _no_poliza,
			   0,
			   _saldo,
			   _diezporc,
			   _prima_bruta
               WITH RESUME;

	end if

end foreach}

{foreach

	select no_poliza,
	       no_documento
	  into _no_poliza,
	       _no_documento
	  from emirepo
	 where user_added = 'AUTOMATI'
	   and estatus <> 5

	let _no_poliza_ult = sp_sis21(_no_documento);

	if _no_poliza <> _no_poliza_ult then

		let _cnt = _cnt + 1;

		select renovada
		  into _estatus
		  from emipomae
		 where no_poliza = _no_poliza
		   and actualizado = 1;

		if _estatus = 1 then


	   	delete from emideren
		 where no_poliza = _no_poliza;

		delete from emirepol
		 where no_poliza = _no_poliza;

		delete from emirepo
		 where no_poliza = _no_poliza;

       RETURN  _no_documento,
       		   _no_poliza,
			   _cnt,0,0,0
               WITH RESUME;
	   end if
	end if

end foreach}

{foreach

	select no_poliza,
	       no_documento
	  into _no_poliza,
	       _no_documento
	  from emirepo
	 where user_added = 'AUTOMATI'
	   and estatus <> 5

	--let _no_poliza_ult = sp_sis21(_no_documento);

	select estatus_poliza
	  into _estatus
	  from emipomae
	 where no_poliza = _no_poliza
	   and actualizado = 1;

	if _estatus = 2 then

		let _cnt = _cnt + 1;

	   	delete from emideren
		 where no_poliza = _no_poliza;

		delete from emirepol
		 where no_poliza = _no_poliza;

		delete from emirepo
		 where no_poliza = _no_poliza;

       RETURN  _no_documento,
       		   _no_poliza,
			   _cnt,0,0,0
               WITH RESUME;

	end if

end foreach}


{foreach

	select no_poliza
	  into _no_poliza
	  from emirepol
	 where no_documento[12,13] = '65'
	   and month(vigencia_final) = 8

	let _cnt = _cnt + 1;

	delete from emideren
	 where no_poliza = _no_poliza;

	delete from emirepol
	 where no_poliza = _no_poliza;

	delete from emirepo
	 where no_poliza = _no_poliza;

	Update emipomae
	   Set cod_no_renov   = '013',
		    fecha_no_renov = today,
		    user_no_renov  = 'VROVIRA',
		    no_renovar     = 1
	 Where no_poliza      = _no_poliza;

end foreach}

{foreach

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_documento[1,2] = '20'
	   and actualizado         = 1
	   and no_renovar          = 0
	   and cod_ramo            = '020'

	let _cnt = _cnt + 1;

    let _no_poliza = sp_sis21(_no_documento);

	 Update emipomae
		Set cod_no_renov   = '013',
		    fecha_no_renov = today,
		    user_no_renov  = 'VROVIRA',
		    no_renovar     = 1
	  Where no_poliza      = _no_poliza;
end foreach}

{foreach

	select e.no_poliza
	  into _no_poliza
	  from emipomae e, emipoagt t
	 where e.no_poliza    = t.no_poliza
	   and e.cod_formapag = '006'	 --forma de pago ancon
	   and t.cod_agente   = '00731'
	   and e.actualizado  = 1

	let _cnt = _cnt + 1;

	 Update emipomae
		Set cobra_poliza = 'E'
	  Where no_poliza    = _no_poliza
	    and actualizado  = 1;

	{ Update endedmae
		Set cod_formapag = '006'
	  Where no_poliza    = _no_poliza
	    and actualizado  = 1;

	 Update endedhis
		Set cod_formapag = '006'
	  Where no_poliza    = _no_poliza;


end foreach
foreach

	select no_poliza,
	       no_documento
	  into _no_poliza,
	       _no_documento
	  from emirepo
	 where user_added = 'FANY'
	   and estatus = 2

		select count(*)
		  into _cnt
		  from emideren
		 where no_poliza = _no_poliza;

		if _cnt = 1 then

		select renglon
		  into _estatus
		  from emideren
		 where no_poliza = _no_poliza;

		if _estatus = 6 then

	       RETURN  _no_documento,
	       		   _no_poliza,
				   _cnt,0,0,0
	               WITH RESUME;
		end if
		end if

end foreach	}


--return "","",_cnt,0,0,0;

end procedure

