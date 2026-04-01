-- Listado de Orden de Reparación

-- Creado    : 09/05/2019 - Autor: Amado Perez M.
-- Modificado: 09/05/2019 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE ap_correo;

CREATE PROCEDURE ap_correo()
RETURNING CHAR(10) AS cod_cliente,
		  VARCHAR(100) AS asegurado,
		  CHAR(50) AS e_mail,
		  CHAR(8) AS usuario,
		  DATE AS fecha,
		  CHAR(2) AS tiene_poliza,
		  VARCHAR(60) AS tipo;
		  
DEFINE _cod_cliente  CHAR(10);
DEFINE _nombre       VARCHAR(100);
DEFINE _user_correo  CHAR(8);
DEFINE _date_correo  DATE;
DEFINE _user_added   CHAR(8);
DEFINE _date_added   DATE;
DEFINE _date_changed DATE;
DEFINE _cnt_1        INTEGER;
DEFINE _usuario      CHAR(8);
DEFINE _fecha        DATE;
DEFINE _e_mail       CHAR(50);
DEFINE _cnt_pol      INTEGER;
define _tipo         VARCHAR(60);
DEFINE _tipo_mov     CHAR(1);

SET ISOLATION TO DIRTY READ;

FOREACH	   
	select a.cod_cliente, 
	       a.nombre, 
		   a.e_mail,
		   a.user_correo,
		   a.date_correo,
		   a.user_added,
		   a.date_added,
		   a.date_changed
	  into _cod_cliente,
	       _nombre,
		   _e_mail,
		   _user_correo,
		   _date_correo,
		   _user_added,
		   _date_added,
		   _date_changed
	  from cliclien a
	  where a.e_mail = 'actualiza@asegurancon.com'
	 order by a.cod_cliente
	 
	select count(*)
      into _cnt_1
      from clibitacora
     where cod_cliente = _cod_cliente
	   and user_changed not like 'CMCOBR%'
	   and user_changed not like 'CMCOMP%'
	   and user_changed <> 'BOSERVER';	  
	 
	if _cnt_1 = 1 then
		let _usuario = _user_added;
		let _fecha = _date_added;	
        let _tipo = "POR IMPORTADOR O USUARIO EN LA PANTALLA DE CLIENTES O WEB";		
	else	
		if _user_correo is not null and trim(_user_correo) <> "" then
			let _usuario = _user_correo;
			let _fecha = _date_correo;		
			let _tipo = "MODIFICADO POR EL USUARIO LA PANTALLA DE CLIENTES";		
		else			
			if _cnt_1 > 1 then
				foreach
					select b.user_changed, 
						   date(b.fecha_modif) as fecha_mod,
						   b.tipo_mov
					  into _usuario,
						   _fecha,
						   _tipo_mov
					  from clibitacora b
					 where b.cod_cliente = _cod_cliente
					   and b.e_mail = 'actualiza@asegurancon.com'
					   and b.user_changed not like 'CMCOBR%'
					   and b.user_changed not like 'CMCOMP%'
					   and b.user_changed <> 'BOSERVER'
				  order by fecha_mod

					 exit foreach;
				end foreach	
				IF _tipo_mov = 'N' THEN
					let _usuario = _user_added;
					let _fecha = _date_added;	
					let _tipo = "POR IMPORTADOR O USUARIO EN LA PANTALLA DE CLIENTES O WEB";	
                ELSE					
					let _tipo = "MODIFICADO EN LA PANTALLA DE CLIENTES DESDE ESTA MAQUINA";				
				END IF
 			end if
	   end if
    end if
  	  	 
    select count(*)
      into _cnt_pol
      from emipouni
     where cod_asegurado = _cod_cliente;
		 
		RETURN _cod_cliente,
		       _nombre,
			   _e_mail,
			   _usuario,
			   _fecha,
			   (case when _cnt_pol > 0 then "SI" else "NO" end),
			   _tipo with resume;   


END FOREACH


END PROCEDURE;