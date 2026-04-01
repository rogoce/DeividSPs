-- Procedure para reclamantes sin fecha de cumpleanos

-- Creado    : 27/07/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - d_prod_sp_pro154_dw1 - DEIVID, S.A.

drop procedure sp_pro158;

create procedure sp_pro158()
returning char(10),
          char(100),
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

set isolation to dirty read;

foreach
 select cod_reclamante
   into _cod_cliente
   from recrcmae
  where periodo[1,4] in ("2004", "2005")
    and numrecla[1,2] = "02"
    and actualizado = 1
  group by cod_reclamante

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

	return _cod_cliente,
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
		   with resume;		   

end foreach

end procedure


























