-- Procedimiento que genera las cartas de Salud
-- Aviso de Cambio de Prima por Cambio de Edad	   
-- Carta para enviar cuando un asegurado principal cumple 30, 40, 45, 50, 55, 60, 65 o 70 anos

-- Creado    : 03/10/2001 - Autor: Marquelda Valdelamar
-- Modificado: 15/10/2001 - Autor: Marquelda Valdelamar
-- Modificado: 12/08/2015 - Autor: Federico Coronado

DROP PROCEDURE "informix".sp_pro76c2bk;

CREATE PROCEDURE "informix".sp_pro76c2bk(
a_compania      CHAR(50),
a_sucursal      CHAR(50),
a_mes           varchar(20),
a_ano           smallint,
a_fecha         date,
a_no_documento  varchar(20)
)RETURNING CHAR(20),      -- No_documento
		   CHAR(50),      -- Nombre del cliente
		   CHAR(50),      -- Direccion_1
		   CHAR(50),      -- Direccion_2
		   DATE,   	      -- Fecha aniversario
		   CHAR(50),      -- Nombre del Agente
		   DECIMAL(16,2), -- Nueva prima
		   DATE,          -- fecha
		   decimal(16,2), -- edad
		   CHAR(50),      -- Nombre de la Compania
		   char(10),			  		         
		   char(10),
		   char(10),		   
		   varchar(50);
		   			  		    
DEFINE _no_poliza  		  		CHAR(10);
DEFINE _cod_agente        		CHAR(5);
DEFINE _cod_ramo          		CHAR(3);
DEFINE _nombre_cliente    		CHAR(50);
DEFINE _nombre_corredor   		CHAR(50);
DEFINE _direccion1		  		CHAR(50);
DEFINE _direccion2        		CHAR(50);
DEFINE _no_documento      		CHAR(20);
DEFINE _cod_asegurado     		CHAR(10);
DEFINE _fecha_aniversario 		DATE;
DEFINE _vigencia_inic     		DATE;
DEFINE _fecha_ani         		DATE;
DEFINE _dia     		  		SMALLINT;
DEFINE _mes	        	  		SMALLINT;
DEFINE _ano		          		SMALLINT;
DEFINE _dia2    		  		SMALLINT;
DEFINE _mes2	    	  		SMALLINT;
DEFINE _ano2		      		SMALLINT;
DEFINE _ano3		      		SMALLINT;
DEFINE _ano4		      		SMALLINT;
DEFINE _edad              		SMALLINT;
DEFINE _prima             		DECIMAL(16,2);
DEFINE _vigencia_final    		DATE;   
DEFINE _fecha_cumpleanos  		DATE;
DEFINE _cod_producto      		CHAR(5);
define _cod_producto_new        char(5);
DEFINE v_compania_nombre  		CHAR(50);
define _telefono1		  		char(10);
define _telefono2		  		char(10);
define _telefono3		  		char(10);
define _nombre_depen      		varchar(50);
define _cod_cliente_depen 		varchar(50);
define _no_unidad         		char(5);
define _cnt               		smallint;
define _activo                  smallint;
define _cant_dep                smallint;
define _fecha_aniversario_depen date;
 	
DEFINE _producto_nuevo     		CHAR(5);
DEFINE v_fecha_ini              date;
DEFINE v_fecha_fin              date;
DEFINE _vigencia_fin       		DATE;   
define _prima_depen             DECIMAL(16,2);
define _edad_depen              SMALLINT; 
define ls_impuesto              DECIMAL(16,2);
define _prima_bruta             DECIMAL(16,2);
define _prima_bruta_dep         DECIMAL(16,2);
define _prima_total             decimal(16,2);
define _prima_endoso             decimal(16,2);
define _prima_total_depen       decimal(16,2);
define _factor_vigencia         decimal(16,2);
define ld_recargo               decimal(16,2);
define ld_recargo_d             decimal(16,2);
define _prima_rec               decimal(16,2);
DEFINE ld_porc_recargo          decimal(16,2);
define _edad_desde              integer;
define _meses                   integer;
define _prima_depen_r           decimal(16,2);
define ls_cod_recargo           decimal(16,2);
define a_periodo                char(7);
define _fecha_hoy               date;
define _inserta                 smallint;
define _fecha_parametro         date;
define _periodo_original        char(7);
define _periodo_ori             char(7);
define _cnt_ducruet             smallint;


 
      CREATE TEMP TABLE tmp_carta(
		no_documento        CHAR(20),    
		nombre_cliente      CHAR(50),  
		direccion1        	CHAR(50),
		direccion2         	CHAR(50),
		fecha_ani		 	date,
		nombre_corredor     CHAR(50),
		prima    	        DEC(16,2),
		fecha               date,  	
		edad                smallint,
		compania_nombre     char(50),
		telefono1           char(10),
		telefono2           char(10),
		telefono3           char(10),
		nombre_depen        varchar(50),
		recargo             decimal(16,2)
		) WITH NO LOG; 
		
     /* CREATE TEMP TABLE tmp_carta_envio(
		no_documento        varchar(20),
		fecha               date,
		usuario             varchar(8),
		enviado        
		) WITH NO LOG; 	
  insert into tmp_carta_envio(no_documento,
							 fecha)
					values(_no_documento,
							current);	  */		

	SET ISOLATION TO DIRTY READ;

	-- Nombre de la Compania
	LET  v_compania_nombre = sp_sis01(a_compania); 
	let _nombre_depen = ' ';
	let _prima        = 0.00;
	let _edad = 0;
	let _fecha_ani = '';
	let _activo = 1;
/*	let _fecha_parametro = a_fecha;
	let _fecha_parametro = _fecha_parametro + 60 units day;
	let _mes = month(_fecha_parametro);
*/
	let _fecha_hoy = current;
	let _prima_depen_r = '';
	let _mes = a_mes[1,2];
	let _periodo_ori = a_ano || "-" ||_mes;
	let a_ano = a_ano - 1;
	let a_periodo = a_ano || "-" ||_mes;
	
	let _periodo_original = _periodo_ori;

	--Ramo de Salud
	SELECT cod_ramo
	  INTO _cod_ramo
	  FROM prdramo
	 WHERE ramo_sis = 5;
	 
	--set debug file to "sp_pro76cbk.trc";
	--trace on;
	let ld_recargo = 0.00;
	FOREACH    
	  SELECT no_poliza,
			 vigencia_inic,
			 no_documento,
			 vigencia_final,
			 factor_vigencia,
			 cod_perpago
		INTO _no_poliza,
			 _vigencia_inic,
			 _no_documento,
			 _vigencia_fin,
			 _factor_vigencia,
			 ls_cod_recargo
		FROM emipomae
	   WHERE cod_ramo        = _cod_ramo 	 
		 AND vigencia_final >= _fecha_hoy
		 AND month(vigencia_inic) = _mes
		 AND actualizado     = 1
		 and colectiva       = "I"
		 and estatus_poliza = 1
		and no_documento   = a_no_documento
	
		let _cnt_ducruet = 0;
	
		select count(*) 
		  into _cnt_ducruet
		  from emipoagt
		 where no_poliza = _no_poliza
		   and cod_agente in ('00815','00035','02154') ;
	
		 SELECT meses
		   INTO _meses
		   FROM cobperpa
		  WHERE cod_perpago = ls_cod_recargo;

		-- Agente de la Poliza
		FOREACH
		 SELECT cod_agente
		   INTO _cod_agente
		   FROM emipoagt
		  WHERE no_poliza = _no_poliza
			 
		 SELECT nombre
		   INTO _nombre_corredor
		   FROM agtagent
		  WHERE cod_agente = _cod_agente;
		 EXIT FOREACH;
		END FOREACH

	--Seleccion de los Asegurados
	FOREACH
		 SELECT cod_asegurado,
				cod_producto,
				no_unidad,
				prima_asegurado
		   INTO	_cod_asegurado,
				_cod_producto,
				_no_unidad,
				_prima
		   FROM emipouni
		  WHERE no_poliza = _no_poliza
		   AND  activo    = 1

		--Datos del Asegurado
		   SELECT nombre, 
				  direccion_1, 
				  direccion_2,
				  fecha_aniversario,
				  telefono1,
				  telefono2,
				  celular
			INTO _nombre_cliente,
				 _direccion1,
				 _direccion2,
				 _fecha_aniversario,
				  _telefono1,
				  _telefono2,
				  _telefono3
			FROM cliclien 
		   WHERE cod_cliente = _cod_asegurado;
		   
	let _edad = 0;
	let _edad_depen = 0;
	let _activo = 1;
	let _inserta = 0;
	
	-- Vigencia inicial y Final
	LET _dia2      		= DAY(_vigencia_inic);
	LET _mes2           = MONTH(_vigencia_inic);
	LET _ano2      		= _periodo_original[1,4];
	LET _vigencia_final = mdy(_mes2,_dia2,_ano2);

	IF _vigencia_fin <= _vigencia_final THEN
		LET _fecha_ani = _vigencia_final;
	ELSE
		LET _ano3      = _periodo_original[1,4];
		LET _fecha_ani = mdy(_mes2,_dia2,_ano3);
	END IF	
	
	let _cod_producto_new = null;
	
	if _cnt_ducruet > 0 then
		if MONTH(_vigencia_inic) <> '02' then
			select producto_nuevo
			  into _cod_producto_new
			  from prdnewpro2
			 where cod_producto = _cod_producto
				and _fecha_ani >= desde
				and _fecha_ani < hasta
				and activo = 1;
		end if
	else
		if MONTH(_vigencia_inic) <> '02' then
			select producto_nuevo
			  into _cod_producto_new
			  from prdnewpro
			 where cod_producto = _cod_producto
				and _fecha_ani >= desde
				and _fecha_ani < hasta
				and activo = 1;
		end if
	end if	
	
	--select producto_nuevo
	--  into _cod_producto_new
	--  from prdnewpro
	-- where cod_producto = _cod_producto
	--   and activo = 1;
		
	if _cod_producto_new is not null then
		let _cod_producto = _cod_producto_new;
	end if
	
	LET _edad = sp_sis78(_fecha_aniversario, _fecha_ani); 

	SELECT prima
	  INTO _prima
	  FROM prdtaeda
	 WHERE cod_producto = _cod_producto
	   AND edad_desde   <= _edad
	   AND edad_hasta   >= _edad;
	
	foreach
		SELECT edad_desde
		  into _edad_desde
		  FROM prdtaeda
		 WHERE cod_producto = _cod_producto
		   and edad_desde > 0
	  order by edad_desde
		  
	---inicio	   
		if YEAR(_fecha_ani) > a_periodo[1,4] then
			if month(_fecha_aniversario) >= month(_fecha_ani) then
				if _inserta = 0 then
					IF a_periodo[1,4] - YEAR(_fecha_aniversario) = _edad_desde THEN                
						LET _edad = a_periodo[1,4] - YEAR(_fecha_aniversario); 
						let _nombre_depen = _nombre_cliente;

						-- Este cambio es solo por un ano (01/09/2005 al 31/08/2006)
						if _vigencia_fin <= "31/08/2006" then
							if MONTH(_vigencia_inic) <> '02' then
								select producto_nuevo
								  into _producto_nuevo
								  from prdnewpro
								 where cod_producto = _cod_producto;

								-- Tarifas Nuevas
								if _producto_nuevo is not null then
									let _cod_producto = _producto_nuevo;
								end if
							end if
						end if

						SELECT prima
						  INTO _prima
						  FROM prdtaeda
						 WHERE cod_producto = _cod_producto
						   AND edad_desde   <= _edad
						   AND edad_hasta   >= _edad;

							let _prima_rec = _prima;
							CALL sp_proe22(_no_poliza, _no_unidad, _prima_rec) RETURNING ld_recargo;
							INSERT INTO tmp_carta(
											  no_documento,    
											  nombre_cliente, 
											  direccion1,      
											  direccion2,      
											  fecha_ani,		
											  nombre_corredor, 
											  prima,    	    
											  fecha,           
											  edad,           
											  compania_nombre, 
											  telefono1,       
											  telefono2,       
											  telefono3,       
											  nombre_depen,
											  recargo)
											  VALUES(  
											  _no_documento,
											  _nombre_cliente,
											  _direccion1,
											  _direccion2,
											  _fecha_ani,
											  _nombre_corredor,
											  _prima,
											  a_fecha,
											  _edad,
											  v_compania_nombre,
											  _telefono1,
											  _telefono2,
											  _telefono3,
											  _nombre_depen,
											  ld_recargo
											  );
						let _activo = 0;
						let ld_recargo = 0;
						let _prima     = 0;
					END IF
				end if
			END IF
		end if
	if year(_fecha_ani) = _periodo_original[1,4] then 
			if month(_fecha_aniversario) <= month(_fecha_ani) then
				if _inserta = 0 then
					IF _periodo_original[1,4] - YEAR(_fecha_aniversario) = _edad_desde THEN            
						LET _edad = (_periodo_original[1,4]) - YEAR(_fecha_aniversario); 
						let _nombre_depen = _nombre_cliente;

						-- Este cambio es solo por un ano (01/09/2005 al 31/08/2006)
						if _vigencia_fin <= "31/08/2006" then
							if MONTH(_vigencia_inic) <> '02' then
								select producto_nuevo
								  into _producto_nuevo
								  from prdnewpro
								 where cod_producto = _cod_producto;
								 
								-- Tarifas Nuevas
								if _producto_nuevo is not null then
									let _cod_producto = _producto_nuevo;
								end if
							end if
						end if
						SELECT prima
						  INTO _prima
						  FROM prdtaeda
						 WHERE cod_producto = _cod_producto
						   AND edad_desde   <= _edad
						   AND edad_hasta   >= _edad;
		
							let _prima_rec = _prima;
							CALL sp_proe22(_no_poliza, _no_unidad, _prima_rec) RETURNING ld_recargo;
														INSERT INTO tmp_carta(
											  no_documento,    
											  nombre_cliente, 
											  direccion1,      
											  direccion2,      
											  fecha_ani,		
											  nombre_corredor, 
											  prima,    	    
											  fecha,           
											  edad,           
											  compania_nombre, 
											  telefono1,       
											  telefono2,       
											  telefono3,       
											  nombre_depen,
											  recargo)
											  VALUES(  
											  _no_documento,
											  _nombre_cliente,
											  _direccion1,
											  _direccion2,
											  _fecha_ani,
											  _nombre_corredor,
											  _prima,
											  a_fecha,
											  _edad,
											  v_compania_nombre,
											  _telefono1,
											  _telefono2,
											  _telefono3,
											  _nombre_depen,
											  ld_recargo
											  );
						let _activo = 0;	
						let ld_recargo = 0;
						let _prima     = 0;						
					end if
				end if
			end if
		end if

	end foreach
	
	--- dependientes	
{ 		  select sum(prima)
		   into _prima_total_depen
		   from emidepen
		  where no_poliza 	= _no_poliza
			and no_unidad 	= _no_unidad
				and activo 	= 1;
					
				if _activo = 1 then	
					let _prima 		   = _prima - _prima_total_depen;	
					let _prima_total   = _prima;
					let _prima_rec     = _prima_total;
					CALL sp_proe22(_no_poliza, _no_unidad, _prima_rec) RETURNING ld_recargo;
				else 
					let _prima_total = 0.00;
				end if
}
		let _prima_total   = _prima;
		--let _prima_total   = 0.00;
	foreach
		select cod_cliente,
			   prima
		  into _cod_cliente_depen,
			   _prima_depen
		  from emidepen
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and activo    = 1
				
		let _activo = 1;
		let _inserta = 0;
				   
		--Datos del Asegurado
	   SELECT nombre, 
			  fecha_aniversario
		 INTO _nombre_depen,
			  _fecha_aniversario_depen
		 FROM cliclien 
		WHERE cod_cliente = _cod_cliente_depen;
		
		LET _edad = sp_sis78(_fecha_aniversario_depen, _fecha_ani); 

		SELECT prima
		  INTO _prima_depen
		  FROM prdtaeda
		 WHERE cod_producto = _cod_producto
		   AND edad_desde   <= _edad
		   AND edad_hasta   >= _edad;

		let _prima_total 	= _prima_depen + _prima_total;
	
		SELECT por_recargo
		  INTO ld_porc_recargo
		  FROM emiderec
		 WHERE no_poliza = _no_poliza  
		   AND no_unidad = _no_unidad
		   AND cod_cliente = _cod_cliente_depen;

		IF ld_porc_recargo IS NULL THEN
			LET ld_porc_recargo = 0.00;
		END IF
				
	   SELECT sum(prima_endoso)
		 INTO _prima_endoso
         FROM prdcobpd
        WHERE cod_producto = _cod_producto;
 
		IF _prima_endoso IS NULL THEN
			LET _prima_endoso = 0.00;
		END IF

		foreach
			SELECT edad_desde
			  into _edad_desde
			  FROM prdtaeda
			 WHERE cod_producto = _cod_producto
			   and edad_desde > 0
	      order by edad_desde

-- inicio	  
			if YEAR(_fecha_ani)  > a_periodo[1,4] then
				if month(_fecha_aniversario_depen) >= month(_fecha_ani) then
					if _inserta = 0 then
						IF a_periodo[1,4] - YEAR(_fecha_aniversario_depen) = _edad_desde THEN
						--	let _prima_total 	  = _prima_total - _prima_depen;
						{	LET _edad_depen = a_periodo[1,4] - YEAR(_fecha_aniversario_depen); 
							
							SELECT prima
							  INTO _prima_depen
							  FROM prdtaeda
							 WHERE cod_producto = _cod_producto
							   AND edad_desde   <= _edad_depen
							   AND edad_hasta   >= _edad_depen;
						}	
							LET _prima_depen_r = _prima_depen /*- _prima_endoso*/;
							LET _prima_depen_r = _prima_depen_r * _meses;
							LET ld_recargo_d = _prima_depen_r * ld_porc_recargo / 100;
							
							IF ld_recargo_d IS NULL THEN
								LET ld_recargo_d = 0.00;
							END IF

							--LET _prima_total 	  = _prima_depen + _prima_total;
								
								INSERT INTO tmp_carta(
														no_documento,    
														nombre_cliente,  
														direccion1,      
														direccion2,      
														fecha_ani,		
														nombre_corredor, 
														prima,    	    
														fecha,           
														edad,            
														compania_nombre, 
														telefono1,       
														telefono2,       
														telefono3,       
														nombre_depen,
														recargo)
														VALUES(  
														_no_documento,
														_nombre_cliente,
														_direccion1,
														_direccion2,
														_fecha_ani,
														_nombre_corredor,
														_prima_total,
														a_fecha,
														_edad,
														v_compania_nombre,
														_telefono1,
														_telefono2,
														_telefono3,
														_nombre_depen,
														ld_recargo_d);
							let _activo = 0;
						end if;
					end if
				end if;
			end if;
				
			if year(_fecha_ani) = _periodo_original[1,4]  then	
				if month(_fecha_aniversario_depen) <= month(_fecha_ani) then
					if _inserta = 0 then
						IF (_periodo_original[1,4]) - YEAR(_fecha_aniversario_depen) = _edad_desde THEN
						--	let _prima_total 	= _prima_total - _prima_depen;
{
							LET _edad_depen = (_periodo_original[1,4]) - YEAR(_fecha_aniversario_depen); 
						  
							SELECT prima
							  INTO _prima_depen
							  FROM prdtaeda
							 WHERE cod_producto = _cod_producto
							   AND edad_desde   <= _edad_depen
							   AND edad_hasta   >= _edad_depen;
}							   
							LET _prima_depen_r = _prima_depen /*- _prima_endoso*/;
							LET _prima_depen_r = _prima_depen_r * _meses;
							LET ld_recargo_d = _prima_depen_r * ld_porc_recargo / 100;
							IF ld_recargo_d IS NULL THEN
								LET ld_recargo_d = 0.00;
							END IF
							 
							--LET _prima_total    = _prima_depen + _prima_total;
								
								INSERT INTO tmp_carta(
														no_documento,    
														nombre_cliente,  
														direccion1,      
														direccion2,      
														fecha_ani,		
														nombre_corredor, 
														prima,    	    
														fecha,           
														edad,            
														compania_nombre, 
														telefono1,       
														telefono2,       
														telefono3,       
														nombre_depen,
														recargo)
														VALUES(  
														_no_documento,
														_nombre_cliente,
														_direccion1,
														_direccion2,
														_fecha_ani,
														_nombre_corredor,
														_prima_total,
														a_fecha,
														_edad,
														v_compania_nombre,
														_telefono1,
														_telefono2,
														_telefono3,
														_nombre_depen,
														ld_recargo_d);
							let _activo = 0;
						end if
					end if
				end if
			end if
-- fin  
		end foreach

				if _activo = 1 then	
				
					--LET _prima_depen_r = _prima_depen - _prima_endoso;
					LET _prima_depen_r = _prima_depen_r * _meses;
					LET ld_recargo_d = _prima_depen_r * ld_porc_recargo / 100;
					IF ld_recargo_d IS NULL THEN
						LET ld_recargo_d = 0.00;
					END IF
					LET ld_recargo = ld_recargo + ld_recargo_d;
						INSERT INTO tmp_carta(
						no_documento,    
						nombre_cliente,  
						direccion1,      
						direccion2,      
						fecha_ani,		
						nombre_corredor, 
						prima,    	    
						fecha,           
						edad,            
						compania_nombre, 
						telefono1,       
						telefono2,       
						telefono3,       
						nombre_depen,
						recargo)
						VALUES(  
						_no_documento,
						_nombre_cliente,
						_direccion1,
						_direccion2,
						_fecha_ani,
						_nombre_corredor,
						_prima_total,
						_fecha_hoy,
						ld_porc_recargo,
						v_compania_nombre,
						_telefono1,
						_telefono2,
						_telefono3,
						'',
						ld_recargo
						);
				end if
			let _prima_total = 0;
			let ld_recargo   = 0;
		end foreach;
		END FOREACH;
	END FOREACH;

	foreach
			select no_documento
			  into _no_documento
			  from tmp_carta
			 where nombre_depen <> ''
		  group by 1
		  order by 1
		  
		foreach	 
			select no_documento,
				   nombre_cliente,
				   direccion1,
				   direccion2,
				   fecha_ani,
				   nombre_corredor,
				   sum(prima),
				   fecha,
				   compania_nombre,
				   telefono1,
				   telefono2,
				   telefono3,
				   nombre_depen,
				   sum(recargo)
			  into  _no_documento,
					 _nombre_cliente,
					 _direccion1,
					 _direccion2,
					 _fecha_ani,
					 _nombre_corredor,
					 _prima_bruta,
					 _fecha_hoy,
					 v_compania_nombre,
					_telefono1,
					_telefono2,
					_telefono3,
					_nombre_depen,
					ld_recargo
			 from tmp_carta
			where no_documento = _no_documento	
			group by 1,2,3,4,5,6,8,9,10,11,12,13
			
				RETURN 
				_no_documento,
				_nombre_cliente,
				_direccion1,
				_direccion2,
				_fecha_ani,
				trim(_nombre_corredor),
				_prima_bruta,
				a_fecha,
				ld_recargo,
				v_compania_nombre,
				_telefono1,
				_telefono2,
				_telefono3,
				_nombre_depen
				WITH RESUME;
		end foreach
	end foreach

	DROP TABLE tmp_carta;

END PROCEDURE;