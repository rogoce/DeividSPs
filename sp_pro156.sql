-- Procedure para el cambio de tarifas por el cambio de edad

-- Creado    : 27/07/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - d_prod_sp_pro154_dw1 - DEIVID, S.A.

drop procedure sp_pro156;

create procedure sp_pro156()
returning char(10),
          char(100),
          char(20),
          date,
		  date,
		  char(50),
		  char(50),
		  char(20),
		  char(30),
		  char(10),
		  char(10),
		  char(10),
		  char(10),
		  char(50);

define _cantidad		smallint;
define _no_poliza		char(10);
define _fecha_nac	  	date;
define _edad		  	smallint;
define _vigencia_inic 	dec(16,2);
define _vigencia_final	dec(16,2);
define _no_documento  	char(20);

define _cod_cliente		char(10);
define _nombre_cliente	char(100);
define _direccion_1		char(50);
define _direccion_2		char(50);
define _apartado		char(20);
define _cedula			char(30);
define _telefono1		char(10);
define _telefono2		char(10);
define _telefono3		char(10);
define _celular			char(10);
define _e_mail			char(50);

define _cant_call		smallint;

set isolation to dirty read;

foreach
 SELECT no_poliza,
		no_documento,
		vigencia_inic,
		vigencia_final
   INTO _no_poliza,
		_no_documento,
		_vigencia_inic,
		_vigencia_final
   FROM emipomae
  WHERE cod_ramo       = "018"
    AND estatus_poliza = 1 -- Vigentes
    AND actualizado    = 1 -- Actualizado
	and cod_tipoprod   in ("001", "005")

	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad > 1 then
		continue foreach;
	end if

	foreach
	 select cod_asegurado
	   into _cod_cliente
	   from emipouni
	  where no_poliza = _no_poliza

		select fecha_aniversario,
		       nombre,
			   direccion_1,
			   direccion_2,
			   apartado,
			   cedula,
			   telefono1,
			   telefono2,
			   telefono3,
			   celular,
			   e_mail
		  into _fecha_nac,
		       _nombre_cliente,
			   _direccion_1,
			   _direccion_2,
			   _apartado,
			   _cedula,
			   _telefono1,
			   _telefono2,
			   _telefono3,
			   _celular,
			   _e_mail
		  from cliclien
		 where cod_cliente = _cod_cliente;
		 
		let _edad = sp_sis78(_fecha_nac, today);
			
		if _edad is not null then
			continue foreach;
		end if

		select count(*)
		  into _cant_call
		  from clienc01
		 where codigo = _cod_cliente;
		 
		if _cant_call <> 0 then
			continue foreach;
		end if

		return _cod_cliente,
			   _nombre_cliente,
			   _no_documento,  
			   _vigencia_inic, 
			   _vigencia_final,
			   _direccion_1,   
			   _direccion_2,   
			   _apartado,	   
			   _cedula,		   
			   _telefono1,	   
			   _telefono2,	   
			   _telefono3,	   
			   _celular,	   
			   _e_mail
			   with resume;		   

	end foreach

end foreach

end procedure


























