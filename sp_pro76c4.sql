-- Procedimiento que genera las cartas de Salud para una póliza
-- Aviso de Cambio de Prima por Cambio de Edad	   
-- Carta para enviar cuando un asegurado o dependiente cumple 30, 40, 45, 50, 55, 60, 65 o 70 anos

-- Creado    :12/08/2015 - Autor: Federico Coronado

DROP PROCEDURE "informix".sp_pro76c4;

CREATE PROCEDURE "informix".sp_pro76c4(
a_compania      CHAR(50),
a_sucursal      CHAR(50),
a_mes           varchar(20),
a_ano           smallint,
a_fecha         date
)RETURNING CHAR(20),      -- No_documento
		   CHAR(50),      -- Nombre del cliente
		   CHAR(10),      -- Cod cliente
		   CHAR(50),      -- Nombre del Agente		   
		   varchar(250),  -- Email Corredor
		   CHAR(50),	  -- Compañia
		   varchar(150),   -- email vacio
		   char(2),
		   smallint;

DEFINE _no_documento      		 CHAR(20);
DEFINE _nombre_cliente    		 CHAR(50);
DEFINE _direccion1		  		 CHAR(50);
DEFINE _direccion2        		 CHAR(50);
DEFINE _fecha_ani				 date;
DEFINE _nombre_corredor   		 CHAR(50);
DEFINE _prima_neta               DECIMAL(16,2);
DEFINE _fecha_carta				 date;
DEFINE v_compania_nombre		 char(50);
define _telefono1		  		 char(10);
define _telefono2		  		 char(10);
define _telefono3		  		 char(10);
define _nombre_dependiente 		 varchar(50);
define ld_recargo                decimal(16,2);
DEFINE _prima_bruta              DECIMAL(16,2);
DEFINE _periodo					 char(7);
define _mes						 char(2);
DEFINE _cod_asegurado     		 CHAR(10);
DEFINE _no_poliza  		  		 CHAR(10);
define _email_corredor			 varchar(250);		
define _email_agtmail			 varchar(50);  
define _email_persona_corredor   varchar(50);  	
define _email_c         		 varchar(250);
define _cod_agente      		 varchar(10); 
define _email_vacio              smallint; 
define _motivo                   varchar(150);
define _enviado                  char(2);
define _cntenviado               smallint;


		   			  		    
SET ISOLATION TO DIRTY READ;
let _mes 		= a_mes[1,2];
let _periodo 	= a_ano || "-" ||_mes;
let _motivo 	= "";
		  
foreach	 
	select no_documento,
		   nombre_cliente,
		   direccion1,
		   direccion2,
		   fecha_ani,
		   nombre_corredor,
		   --sum(prima),
		   fecha,
		   compania,
		   --telefono1,
		   --telefono2,
		   --telefono3,
		   --nombre_dependiente,
		   --sum(recargo),
		   --sum(prima_total),
		   email_vacio
	  into  _no_documento,
			 _nombre_cliente,
			 _direccion1,
			 _direccion2,
			 _fecha_ani,
			 _nombre_corredor,
			-- _prima_neta,
			 _fecha_carta,
			 v_compania_nombre,
			--_telefono1,
			--_telefono2,
			--_telefono3,
			--_nombre_dependiente,
			--ld_recargo,
			--_prima_bruta,
			_email_vacio
	 from enviocartadet
	where fecha = a_fecha
	  and periodo = _periodo
	  --and email_vacio = 0
	  and email_vacio <> 1
	group by 1,2,3,4,5,6,7,8,9, email_vacio
	order by  email_vacio asc
	
	let _no_poliza 		= sp_sis21(_no_documento);
	let _email_c = "";
	--Seleccion de los Asegurados
	FOREACH
		 SELECT cod_asegurado
		   INTO	_cod_asegurado
		   FROM emipouni
		  WHERE no_poliza = _no_poliza
		   AND  activo    = 1
		exit foreach;
	end foreach
	
    foreach
	   select cod_agente
		 into _cod_agente
		 from emipoagt
		where no_poliza =  _no_poliza
		
		select e_mail,
		       email_personas
		  into _email_corredor,
			   _email_persona_corredor
		 from agtagent
		where cod_agente = _cod_agente;
		
		
		
		if _email_persona_corredor is null or trim(_email_persona_corredor) = '' then
			--let _email_c = trim(_email_corredor) || '; ' || _email_c;
			let _email_c = "";
		else
			foreach
				Select email
				  into _email_agtmail
				  from agtmail
				 where cod_agente = _cod_agente
				   and tipo_correo = 'PER'
				
					if trim(_email_agtmail) = '' or _email_agtmail is null then
						continue foreach;
					end if
						let _email_c = trim(_email_agtmail) || '; ' || trim(_email_c);
			end foreach
			let _email_c = trim(_email_persona_corredor) || '; ' || _email_c;
		end if
		
		if _email_corredor is not null and trim(_email_corredor) <> '' then
			let _email_c = trim(_email_corredor) || '; ' || _email_c; 
		end if
		
	end foreach
if _email_vacio = 0 then
	let _motivo = "Asegurados sin direccion de correo electronico."; --Vacio
elif _email_vacio = 2 then
	let _motivo = "Asegurados con errores en la direccion de correo electronico.";
elif _email_vacio = 3 then
	let _motivo = "Corredores con errores en la direccion de correo electronico.";
elif _email_vacio = 5 then
	let _motivo = "Corredores sin direccion de correo electronico.";
else
	let _motivo = "Asegurados y corredores con errores en la direccion de correo electronico."; --Cliente y Corredor
end if

foreach
   select enviado
     into _cntenviado
     from enviocarta
	where fecha = a_fecha
	  and periodo = _periodo
	  and no_documento = _no_documento
	exit foreach;
end foreach 

	if _cntenviado = 1 then
		let _enviado = "SI";
	else
		let _enviado = "NO";
	end if	
		RETURN 
		_no_documento,
		_nombre_cliente,
		_cod_asegurado,
		trim(_nombre_corredor),
		trim(_email_c),
		v_compania_nombre,
		upper(trim(_motivo)),
		_enviado,
		_email_vacio
		WITH RESUME;
end foreach

END PROCEDURE;