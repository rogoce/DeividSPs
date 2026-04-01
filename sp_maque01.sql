-- POLIZAS VIGENTES 
--

   DROP procedure sp_maque01;
   CREATE procedure sp_maque01()
   RETURNING char(10),char(50),char(30),char(10),char(50),date,char(1),char(5),char(50),char(3),char(50),char(3),char(50),char(3),char(50),char(50),char(4);

    DEFINE _no_poliza,_telefono1,_cod_contratante	 	   CHAR(10);
    DEFINE _no_documento    						       CHAR(20);
    DEFINE _cod_agente      						       CHAR(5);
    DEFINE _n_contratante,_n_agente,_n_forma_pago,_n_ruta  CHAR(50);
	define _vi,_vf,_fecha_aniversario		    		date;
	define _cod_formapag,_cod_ramo,_cod_subramo			CHAR(3);
	define _tipo_cte              char(4);
	define _cod_ruta        	  char(2);
	define _pro_cotizacion,_cant  integer;
	define _cedula                varchar(30);
	define _e_mail,_n_ramo,_n_subramo  varchar(50);
	define _sexo,_tipo_agente,_tipo_cliente          char(1);
	
foreach
	select distinct e.no_documento
	  into _no_documento
	  from emipomae e
	 where e.actualizado = 1
	   and e.estatus_poliza = 1
	   and e.cod_grupo in('00001')
	
	let _no_poliza = sp_sis21(_no_documento);
	
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;   
	end foreach
	
	select e.no_documento,
		   e.cod_contratante,
		   e.vigencia_inic,
		   e.vigencia_final,
		   e.cod_formapag,
		   e.cod_ramo,
		   e.cod_subramo
	  into _no_documento,
		   _cod_contratante,
		   _vi,
		   _vf,
		   _cod_formapag,
		   _cod_ramo,
		   _cod_subramo
	  from emipomae e
	 where e.no_poliza = _no_poliza;
	   
	select nombre,
	       tipo_agente
	  into _n_agente,
	       _tipo_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	if _tipo_agente <> 'O' then		--Solo corredor directo
		continue foreach;
	end if

	select nombre,
	       actual_potencial,
		   cedula,
		   telefono1,
		   e_mail,
		   fecha_aniversario,
		   sexo,
		   cod_ruta
	  into _n_contratante,
	       _tipo_cliente,
		   _cedula,
		   _telefono1,
		   _e_mail,
		   _fecha_aniversario,
		   _sexo,
		   _cod_ruta
	  from cliclien
	 where cod_cliente = _cod_contratante;
		 
	if _tipo_cliente = '3' then	--asegurados
		let _tipo_cte = 'ASEG';
	elif _tipo_cliente = '1' then --proveedor
		let _tipo_cte = 'PROV';
	elif _tipo_cliente = '2' then --afectado
		let _tipo_cte = 'AFEC';
	else
		let _tipo_cte = 'OTRO';
	end if

--Nombre, cedula, teléfono, correo, fecha de nacimiento, género, corredor, forma de pago, ramo, sub ramo, ruta de pago.		 
	select nombre into _n_forma_pago from cobforpa
	where cod_formapag = _cod_formapag;
	
	select nombre
	  into _n_ruta
	  from chqruta
	 where cod_ruta = _cod_ruta;
	 
	select nombre
	  into _n_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	 
	select nombre
	  into _n_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	return _cod_contratante,_n_contratante,_cedula,_telefono1,_e_mail,_fecha_aniversario,_sexo,_cod_agente,_n_agente,_cod_formapag,_n_forma_pago,
	       _cod_ramo,_n_ramo,_cod_subramo,_n_subramo,_n_ruta,_tipo_cte with resume;

end foreach
END PROCEDURE;
