-- Inicio : 10/08/2007 - Autor: Arn ez Rub‚n
-- Procedimiento para agrupar el control de Preautorizaciones

DROP PROCEDURE sp_rec147a;
CREATE PROCEDURE sp_rec147a(a_aprob char(10) DEFAULT '*', a_fecha date, a_fechaf date, a_estado smallint, a_reclamante char(10) default '*', a_poliza char(20) default '*')
returning char(10)		as no_certificado,					   						-- 1. N£mero de Aprovaci¢n 
		  char(10)		as cod_asegurado,					   					   	-- 2. Codigo del Reclamante 
		  char(100)	as asegurado,                   						-- 3. Nombre del Reclamante 
		  char(20)		as poliza,					   						-- 4. P¢liza 
		  datetime year to fraction(5) as fecha_solicitud,						-- 5. Fecha de la Solicitud
		  datetime year to fraction(5) as fecha_autorizacion,						-- 6. Fecha de autorizaci¢n
		  char(10)	as autorizado_por,											-- 7. Autorizado por:
		  char(18)	as estatus,					   						-- 8. Estado 
		  char(100) as diagnostico,                                        -- 9. Dx
		  char(100) as Procedimiento,										--10. Pct
		  char(10)	as cod_proveedor,
		  char(100)	as proveedor,
		  char(2)	as anestesia,
		  dec(16,2)	as dias,
		  datetime year to fraction(5)	as fecha_scan,
		  char(10)	as usuario_scan,
          char(5)	as cod_producto,
          char(50)	as producto,
          char(50)	as tipo_carnet,
          dec(16,2) as hono_medico;		  
											
define _no_aprobacion	    char(10);
define _fecha_solicitud     datetime year to fraction(5);
define _fecha_autorizacion,_fecha_esc  datetime year to fraction(5);
define _no_documento	    char(20);
define _cod_reclamante,_no_poliza	    char(10);
define _reclamante,_n_proveedor	        char(100);
define _no_unidad,_cod_producto    char(5);
define _n_producto,_n_tipo_carnet  char(50);
define _autorizado_por      char(10);
define _estado,_anestesia,_total_dias              smallint;
define _hono_medico         dec(16,2);
define _idx                 char(100);
define _idx1                char(10);
define _idx2                char(10);
define _idx3                char(10);
define _idx4                char(10);
define _idx5                char(10);
define _idx6                char(10);
define _idx7                char(10);
define _idx8                char(10);
define _idx9                char(10);
define _idx10               char(10);
define _n_estado            char(18);
define _ipct               char(100);
define _ipct1,_cod_cliente               char(10);
define _ipct2               char(10);
define _ipct3               char(10);
define _ipct4               char(10);
define _ipct5               char(10);
define _ipct6               char(10);
define _ipct7               char(10);
define _ipct8               char(10);
define _ipct9               char(10);
define _ipct10,_user_esc              char(10);
define _tab,_n_anestesia              char(2);
define _cod_carnet           char(3);
define _diagnosticos       char(100);
define _procedimientos     char(100);

let _tab = "/";

SET ISOLATION TO DIRTY READ;

if a_poliza <> "*" then
   foreach
		SELECT  no_aprobacion,
			    cod_reclamante,
			    no_documento,
			    autorizado_por,
			    fecha_solicitud,
			    fecha_autorizacion,
				decode(estado,0,'PENDIENTES',1,'AUTORIZADAS',2,'NO AUTORIZADAS'),
				(case  cod_icd1  when  null then '' else  trim(cod_icd1)     end ),
      			(case  cod_icd2  when  null then '' else  trim(cod_icd2)     end ),
      			(case  cod_icd3  when  null then '' else  trim(cod_icd3)     end ),
      			(case  cod_icd4  when  null then '' else  trim(cod_icd4)     end ),
      			(case  cod_icd5  when  null then '' else  trim(cod_icd5)     end ),
      			(case  cod_icd6  when  null then '' else  trim(cod_icd6)     end ),
      			(case  cod_icd7  when  null then '' else  trim(cod_icd7)     end ),
      			(case  cod_icd8  when  null then '' else  trim(cod_icd8)     end ),
      			(case  cod_icd9  when  null then '' else  trim(cod_icd9)     end ),
      			(case  cod_icd10 when  null then '' else trim(cod_icd10)     end ),
      			(case  cod_cpt1  when  null then  '' else trim(cod_cpt1)     end ),
      			(case  cod_cpt2  when  null then  '' else trim(cod_cpt2)     end ),
      			(case  cod_cpt3  when  null then  '' else trim(cod_cpt3)     end ),
      			(case  cod_cpt4  when  null then  '' else trim(cod_cpt4)     end ),
      			(case  cod_cpt5  when  null then  '' else trim(cod_cpt5)     end ),
      			(case  cod_cpt6  when  null then  '' else trim(cod_cpt6)     end ),
      			(case  cod_cpt7  when  null then  '' else trim(cod_cpt7)     end ),
      			(case  cod_cpt8  when  null then  '' else trim(cod_cpt8)     end ),
      			(case  cod_cpt9  when  null then  '' else trim(cod_cpt9)     end ),
      			(case  cod_cpt10 when  null then  '' else trim(cod_cpt10)    end ),
				cod_cliente,
				anestesia,
				total_dias,
				fecha_escaneado,
				user_escaneado,
				hono_medico
		  INTO  _no_aprobacion,
		        _cod_reclamante,
			    _no_documento,
			    _autorizado_por,
			    _fecha_solicitud,
			    _fecha_autorizacion,
				_n_estado,
				_idx1,
				_idx2,
				_idx3,
				_idx4,
				_idx5,
				_idx6,
				_idx7,
				_idx8,
				_idx9,
				_idx10,
				_ipct1,
				_ipct2,
				_ipct3,
				_ipct4,
				_ipct5,
				_ipct6,
				_ipct7,
				_ipct8,
				_ipct9,
				_ipct10,
				_cod_cliente,
				_anestesia,
				_total_dias,
				_fecha_esc,
				_user_esc,
				_hono_medico
		   FROM recprea1
          WHERE no_documento = a_poliza
		  
	   	 SELECT nombre
		   INTO _reclamante
		   FROM cliclien
		  WHERE cod_cliente = _cod_reclamante;
		  
		if _anestesia = 0 then
			let _n_anestesia = 'SI';
        else
			let _n_anestesia = 'NO';
        end if		  
		  
	   	 SELECT nombre
		   INTO _n_proveedor
		   FROM cliclien
		  WHERE cod_cliente = _cod_cliente;
		  
		foreach
			select no_poliza,
				   no_unidad
			  into _no_poliza,
				   _no_unidad
			  from recrcmae
			 where no_documento = _no_documento
			   and cod_reclamante = cod_reclamante
			exit foreach;
		end foreach
		
		select cod_producto 
		  into _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza
           and no_unidad = _no_unidad;
		   
		select nombre,cod_carnet
		  into _n_producto,_cod_carnet
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		select nombre into _n_tipo_carnet from emicarnet
		where cod_carnet = _cod_carnet;
		   
		 LET  _procedimientos =  "";
		 LET  _diagnosticos   =  "";

		IF _ipct1 <> '' THEN
   		   SELECT nombre
   			 INTO _ipct
   			 FROM reccpt
   			WHERE cod_cpt = _ipct1;
  			LET  _procedimientos = _ipct;
		END IF

		IF _ipct2 <> '' THEN
   		   SELECT nombre
   		     INTO _ipct
   		     FROM reccpt
   		    WHERE cod_cpt = _ipct2;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct3 <> '' THEN
		   SELECT nombre
		     INTO _ipct
		     FROM reccpt
		    WHERE cod_cpt = _ipct3;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct4 <> '' THEN
   			SELECT nombre 
   			  INTO _ipct 
   			  FROM reccpt 
   			 WHERE cod_cpt = _ipct4;
   			 LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct5 <> '' THEN
   		   SELECT nombre
   		     INTO _ipct
   		     FROM reccpt
   		    WHERE cod_cpt = _ipct5;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct6 <> '' THEN
	   	   SELECT nombre
	   	   	 INTO _ipct
	   	   	 FROM reccpt
	   	   	WHERE cod_cpt = _ipct6;
   		    LET _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct7 <> '' THEN
   		   SELECT nombre 
   		     INTO _ipct 
   		     FROM reccpt 
   		    WHERE cod_cpt = _ipct7;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct8 <> '' THEN
		   SELECT nombre
		   	 INTO _ipct
		     FROM reccpt
		    WHERE cod_cpt = _ipct8;
   			LET _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct9 <> '' THEN
   		   SELECT nombre
   		     INTO _ipct
   		     FROM reccpt
   		    WHERE cod_cpt = _ipct9;
		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		 IF _ipct10 <> '' THEN
		    SELECT nombre 
		      INTO _ipct
		      FROM reccpt
		     WHERE cod_cpt = _ipct10;
		     LET   _procedimientos = _procedimientos || _tab || _ipct;
		 END IF

		 IF _idx1 <> '' THEN
		 	SELECT nombre
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx1;
   			 LET   _diagnosticos = _idx;
		 END IF

		 IF _idx2 <> '' THEN
   			SELECT nombre
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx2;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx3 <> '' THEN
   			SELECT nombre 
   			  INTO _idx 
   			  FROM recicd 
   			 WHERE cod_icd = _idx3;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx4 <> '' THEN
   			SELECT nombre 
   			  INTO _idx 
   			  FROM recicd 
   			 WHERE cod_icd = _idx4;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx5 <> '' THEN
   			SELECT nombre 
   			  INTO _idx 
   			  FROM recicd 
   			 WHERE cod_icd = _idx5;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx6 <> '' THEN
		    SELECT nombre 
		      INTO _idx 
		      FROM recicd 
		     WHERE cod_icd = _idx6;
		     LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx7 <> '' THEN
   		    SELECT nombre 
   		      INTO _idx 
   		      FROM recicd 
   		     WHERE  cod_icd = _idx7;
   		     LET _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx8 <> '' THEN
   			SELECT nombre 
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx8;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx9 <> '' THEN
   			SELECT nombre
   			  INTO _idx
   			  FROM recicd 
   			 WHERE cod_icd = _idx9;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
	     END IF

		 IF _idx10 <> '' THEN
		    SELECT nombre 
		      INTO _idx 
		      FROM recicd 
		     WHERE  cod_icd = _idx10;
   		     LET _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

	     return _no_aprobacion,		 --1
	   	        _cod_reclamante,	 --2
			    _reclamante,		 --3
			    _no_documento,		 --4
			    _fecha_solicitud,	 --5
			    _fecha_autorizacion, --6
			    _autorizado_por,	 --7
			    _n_estado,			 --8
				_diagnosticos,       --9
				_procedimientos,   	--10
				_cod_cliente,
				_n_proveedor,
				_n_anestesia,
				_total_dias,
				_fecha_esc,
				_user_esc,
				_cod_producto,
				_n_producto,
				_n_tipo_carnet,
				_hono_medico
		   with resume;
	end foreach
else
if a_estado <> 3 then 
		
   foreach
		SELECT  no_aprobacion,
			    cod_reclamante,
			    no_documento,
			    autorizado_por,
			    fecha_solicitud,
			    fecha_autorizacion,
				decode(estado,0,'PENDIENTES',1,'AUTORIZADAS',2,'NO AUTORIZADAS'),
				(case  cod_icd1  when  null then '' else  trim(cod_icd1)     end ),
      			(case  cod_icd2  when  null then '' else  trim(cod_icd2)     end ),
      			(case  cod_icd3  when  null then '' else  trim(cod_icd3)     end ),
      			(case  cod_icd4  when  null then '' else  trim(cod_icd4)     end ),
      			(case  cod_icd5  when  null then '' else  trim(cod_icd5)     end ),
      			(case  cod_icd6  when  null then '' else  trim(cod_icd6)     end ),
      			(case  cod_icd7  when  null then '' else  trim(cod_icd7)     end ),
      			(case  cod_icd8  when  null then '' else  trim(cod_icd8)     end ),
      			(case  cod_icd9  when  null then '' else  trim(cod_icd9)     end ),
      			(case  cod_icd10 when  null then '' else trim(cod_icd10)     end ),

      			(case  cod_cpt1  when  null then  '' else trim(cod_cpt1)     end ),
      			(case  cod_cpt2  when  null then  '' else trim(cod_cpt2)     end ),
      			(case  cod_cpt3  when  null then  '' else trim(cod_cpt3)     end ),
      			(case  cod_cpt4  when  null then  '' else trim(cod_cpt4)     end ),
      			(case  cod_cpt5  when  null then  '' else trim(cod_cpt5)     end ),
      			(case  cod_cpt6  when  null then  '' else trim(cod_cpt6)     end ),
      			(case  cod_cpt7  when  null then  '' else trim(cod_cpt7)     end ),
      			(case  cod_cpt8  when  null then  '' else trim(cod_cpt8)     end ),
      			(case  cod_cpt9  when  null then  '' else trim(cod_cpt9)     end ),
      			(case  cod_cpt10 when  null then  '' else trim(cod_cpt10)    end ),
				cod_cliente,
				anestesia,
				total_dias,
				fecha_escaneado,
				user_escaneado,
				hono_medico
		  INTO  _no_aprobacion,
		        _cod_reclamante,
			    _no_documento,
			    _autorizado_por,
			    _fecha_solicitud,
			    _fecha_autorizacion,
				_n_estado,
				_idx1,
				_idx2,
				_idx3,
				_idx4,
				_idx5,
				_idx6,
				_idx7,
				_idx8,
				_idx9,
				_idx10,
				_ipct1,
				_ipct2,
				_ipct3,
				_ipct4,
				_ipct5,
				_ipct6,
				_ipct7,
				_ipct8,
				_ipct9,
				_ipct10,
				_cod_cliente,
				_anestesia,
				_total_dias,
				_fecha_esc,
				_user_esc,
				_hono_medico				
		   FROM recprea1
          WHERE date(fecha_solicitud) between a_fecha AND a_fechaf
		    AND estado                = a_estado
			AND no_aprobacion         MATCHES a_aprob
			AND cod_reclamante        MATCHES a_reclamante

	   	 SELECT nombre
		   INTO _reclamante
		   FROM cliclien
		  WHERE cod_cliente = _cod_reclamante;
		  
	   	 SELECT nombre
		   INTO _n_proveedor
		   FROM cliclien
		  WHERE cod_cliente = _cod_cliente;
		if _anestesia = 0 then
			let _n_anestesia = 'SI';
        else
			let _n_anestesia = 'NO';
        end if		  
		  
	   	 SELECT nombre
		   INTO _n_proveedor
		   FROM cliclien
		  WHERE cod_cliente = _cod_cliente;
		  
		foreach
			select no_poliza,
				   no_unidad
			  into _no_poliza,
				   _no_unidad
			  from recrcmae
			 where no_documento = _no_documento
			   and cod_reclamante = cod_reclamante
			exit foreach;
		end foreach
		
		select cod_producto 
		  into _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza
           and no_unidad = _no_unidad;
		   
		select nombre,cod_carnet
		  into _n_producto,_cod_carnet
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		select nombre into _n_tipo_carnet from emicarnet
		where cod_carnet = _cod_carnet;		  

		 LET  _procedimientos =  "";
		 LET  _diagnosticos  =  "";

		IF _ipct1 <> '' THEN
   		   SELECT nombre
   			 INTO _ipct
   			 FROM reccpt
   			WHERE cod_cpt = _ipct1;
  			LET  _procedimientos = _ipct;
		END IF

		IF _ipct2 <> '' THEN
   		   SELECT nombre
   		     INTO _ipct
   		     FROM reccpt
   		    WHERE cod_cpt = _ipct2;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct3 <> '' THEN
		   SELECT nombre
		     INTO _ipct
		     FROM reccpt
		    WHERE cod_cpt = _ipct3;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct4 <> '' THEN
   			SELECT nombre
   			  INTO _ipct
   			  FROM reccpt
   			 WHERE cod_cpt = _ipct4;
   			 LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct5 <> '' THEN
   		   SELECT nombre
   		     INTO _ipct
   		     FROM reccpt
   		    WHERE cod_cpt = _ipct5;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct6 <> '' THEN
	   	   SELECT nombre
	   	   	 INTO _ipct
	   	   	 FROM reccpt
	   	   	WHERE cod_cpt = _ipct6;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct7 <> '' THEN
   		   SELECT nombre
   		     INTO _ipct
   		     FROM reccpt
   		    WHERE cod_cpt = _ipct7;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct8 <> '' THEN
		   SELECT nombre
		   	 INTO _ipct
		     FROM reccpt
		    WHERE cod_cpt = _ipct8;
   			LET _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct9 <> '' THEN
   		   SELECT nombre
   		     INTO _ipct
   		     FROM reccpt
   		    WHERE cod_cpt = _ipct9;
		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		 IF _ipct10 <> '' THEN
		    SELECT nombre 
		      INTO _ipct
		      FROM reccpt
		     WHERE cod_cpt = _ipct10;
		     LET   _procedimientos = _procedimientos || _tab || _ipct;
		 END IF

		 IF _idx1 <> '' THEN
		 	SELECT nombre
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx1;
   			 LET   _diagnosticos = _idx;
		 END IF

		 IF _idx2 <> '' THEN
   			SELECT nombre
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx2;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx3 <> '' THEN
   			SELECT nombre 
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx3;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx4 <> '' THEN
   			SELECT nombre
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx4;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx5 <> '' THEN
   			SELECT nombre
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx5;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx6 <> '' THEN
		    SELECT nombre
		      INTO _idx
		      FROM recicd
		     WHERE cod_icd = _idx6;
		     LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx7 <> '' THEN
   		    SELECT nombre
   		      INTO _idx
   		      FROM recicd
   		     WHERE cod_icd = _idx7;
   		     LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx8 <> '' THEN
   			SELECT nombre 
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx8;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx9 <> '' THEN
   			SELECT nombre
   			  INTO _idx
   			  FROM recicd 
   			 WHERE cod_icd = _idx9;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
	     END IF

		 IF _idx10 <> '' THEN
		    SELECT nombre 
		      INTO _idx 
		      FROM recicd 
		     WHERE cod_icd = _idx10;
   		     LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

	     return _no_aprobacion,		 --1
	   	        _cod_reclamante,	 --2
			    _reclamante,		 --3
			    _no_documento,		 --4
			    _fecha_solicitud,	 --5
			    _fecha_autorizacion, --6
			    _autorizado_por,	 --7
			    _n_estado,		   	 --8
				_diagnosticos,       --9
				_procedimientos,   	--10
				_cod_cliente,
				_n_proveedor,
				_n_anestesia,
				_total_dias,
				_fecha_esc,
				_user_esc,
				_cod_producto,
				_n_producto,
				_n_tipo_carnet,
				_hono_medico
		   with resume;
	 
	end foreach
else
   foreach
	    
		SELECT  no_aprobacion,
			    cod_reclamante,
			    no_documento,
			    autorizado_por,
			    fecha_solicitud,
			    fecha_autorizacion,
				decode(estado,0,'PENDIENTES',1,'AUTORIZADAS',2,'NO AUTORIZADAS'),
				(case  cod_icd1  when  null then '' else  trim(cod_icd1)     end ),
      			(case  cod_icd2  when  null then '' else  trim(cod_icd2)     end ),
      			(case  cod_icd3  when  null then '' else  trim(cod_icd3)     end ),
      			(case  cod_icd4  when  null then '' else  trim(cod_icd4)     end ),
      			(case  cod_icd5  when  null then '' else  trim(cod_icd5)     end ),
      			(case  cod_icd6  when  null then '' else  trim(cod_icd6)     end ),
      			(case  cod_icd7  when  null then '' else  trim(cod_icd7)     end ),
      			(case  cod_icd8  when  null then '' else  trim(cod_icd8)     end ),
      			(case  cod_icd9  when  null then '' else  trim(cod_icd9)     end ),
      			(case  cod_icd10 when  null then '' else trim(cod_icd10)     end ),

      			(case  cod_cpt1  when  null then  '' else trim(cod_cpt1)     end ),
      			(case  cod_cpt2  when  null then  '' else trim(cod_cpt2)     end ),
      			(case  cod_cpt3  when  null then  '' else trim(cod_cpt3)     end ),
      			(case  cod_cpt4  when  null then  '' else trim(cod_cpt4)     end ),
      			(case  cod_cpt5  when  null then  '' else trim(cod_cpt5)     end ),
      			(case  cod_cpt6  when  null then  '' else trim(cod_cpt6)     end ),
      			(case  cod_cpt7  when  null then  '' else trim(cod_cpt7)     end ),
      			(case  cod_cpt8  when  null then  '' else trim(cod_cpt8)     end ),
      			(case  cod_cpt9  when  null then  '' else trim(cod_cpt9)     end ),
      			(case  cod_cpt10 when  null then  '' else trim(cod_cpt10)    end ),
				cod_cliente,
				anestesia,
				total_dias,
				fecha_escaneado,
				user_escaneado,
				hono_medico
		  INTO  _no_aprobacion,
		        _cod_reclamante,
			    _no_documento,
			    _autorizado_por,
			    _fecha_solicitud,
			    _fecha_autorizacion,
				_n_estado,
				_idx1,
				_idx2,
				_idx3,
				_idx4,
				_idx5,
				_idx6,
				_idx7,
				_idx8,
				_idx9,
				_idx10,
				_ipct1,
				_ipct2,
				_ipct3,
				_ipct4,
				_ipct5,
				_ipct6,
				_ipct7,
				_ipct8,
				_ipct9,
				_ipct10,
				_cod_cliente,
				_anestesia,
				_total_dias,
				_fecha_esc,
				_user_esc,
				_hono_medico				
		  FROM recprea1
          WHERE date(fecha_solicitud) between a_fecha AND a_fechaf
			AND no_aprobacion         MATCHES a_aprob
			AND cod_reclamante        MATCHES a_reclamante

	   	 SELECT nombre
		   INTO _reclamante
		   FROM cliclien
		  WHERE cod_cliente = _cod_reclamante;

	   	 SELECT nombre
		   INTO _n_proveedor
		   FROM cliclien
		  WHERE cod_cliente = _cod_cliente;
		if _anestesia = 0 then
			let _n_anestesia = 'SI';
        else
			let _n_anestesia = 'NO';
        end if		  
		  
	   	 SELECT nombre
		   INTO _n_proveedor
		   FROM cliclien
		  WHERE cod_cliente = _cod_cliente;
		  
		foreach
			select no_poliza,
				   no_unidad
			  into _no_poliza,
				   _no_unidad
			  from recrcmae
			 where no_documento = _no_documento
			   and cod_reclamante = cod_reclamante
			exit foreach;
		end foreach
		
		select cod_producto 
		  into _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza
           and no_unidad = _no_unidad;
		   
		select nombre,cod_carnet
		  into _n_producto,_cod_carnet
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		select nombre into _n_tipo_carnet from emicarnet
		where cod_carnet = _cod_carnet;		  

		 LET  _procedimientos =  "";
		 LET  _diagnosticos  =  "";

		IF _ipct1 <> '' THEN
   		   SELECT nombre
   			 INTO _ipct
   			 FROM reccpt
   			WHERE cod_cpt = _ipct1;
  			LET  _procedimientos = _ipct;
		END IF

		IF _ipct2 <> '' THEN
   		   SELECT nombre
   		     INTO _ipct
   		     FROM reccpt
   		    WHERE cod_cpt = _ipct2;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct3 <> '' THEN
		   SELECT nombre
		     INTO _ipct
		     FROM reccpt
		    WHERE cod_cpt = _ipct3;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct4 <> '' THEN
   			SELECT nombre 
   			  INTO _ipct 
   			  FROM reccpt 
   			 WHERE cod_cpt = _ipct4;
   			 LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct5 <> '' THEN
   		   SELECT nombre
   		     INTO _ipct
   		     FROM reccpt
   		    WHERE cod_cpt = _ipct5;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct6 <> '' THEN
	   	   SELECT nombre
	   	   	 INTO _ipct
	   	   	 FROM reccpt
	   	   	WHERE cod_cpt = _ipct6;
   		    LET _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct7 <> '' THEN
   		   SELECT nombre 
   		     INTO _ipct 
   		     FROM reccpt 
   		    WHERE cod_cpt = _ipct7;
   		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct8 <> '' THEN
		   SELECT nombre
		   	 INTO _ipct
		     FROM reccpt
		    WHERE cod_cpt = _ipct8;
   			LET _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		IF _ipct9 <> '' THEN
   		   SELECT nombre
   		     INTO _ipct
   		     FROM reccpt
   		    WHERE cod_cpt = _ipct9;
		    LET   _procedimientos = _procedimientos || _tab || _ipct;
		END IF

		 IF _ipct10 <> '' THEN
		    SELECT nombre 
		      INTO _ipct
		      FROM reccpt
		     WHERE cod_cpt = _ipct10;
		     LET   _procedimientos = _procedimientos || _tab || _ipct;
		 END IF

		 IF _idx1 <> '' THEN
		 	SELECT nombre
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx1;
   			 LET   _diagnosticos = _idx;
		 END IF

		 IF _idx2 <> '' THEN
   			SELECT nombre
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx2;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx3 <> '' THEN
   			SELECT nombre 
   			  INTO _idx 
   			  FROM recicd 
   			 WHERE cod_icd = _idx3;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx4 <> '' THEN
   			SELECT nombre 
   			  INTO _idx 
   			  FROM recicd 
   			 WHERE cod_icd = _idx4;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx5 <> '' THEN
   			SELECT nombre 
   			  INTO _idx 
   			  FROM recicd 
   			 WHERE cod_icd = _idx5;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx6 <> '' THEN
		    SELECT nombre 
		      INTO _idx 
		      FROM recicd 
		     WHERE cod_icd = _idx6;
		     LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx7 <> '' THEN
   		    SELECT nombre 
   		      INTO _idx 
   		      FROM recicd 
   		     WHERE  cod_icd = _idx7;
   		     LET _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx8 <> '' THEN
   			SELECT nombre 
   			  INTO _idx
   			  FROM recicd
   			 WHERE cod_icd = _idx8;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

		 IF _idx9 <> '' THEN
   			SELECT nombre
   			  INTO _idx
   			  FROM recicd 
   			 WHERE cod_icd = _idx9;
   			 LET   _diagnosticos = _diagnosticos || _tab || _idx;
	     END IF

		 IF _idx10 <> '' THEN
		    SELECT nombre
		      INTO _idx 
		      FROM recicd 
		     WHERE  cod_icd = _idx10;
   		     LET _diagnosticos = _diagnosticos || _tab || _idx;
		 END IF

	     return _no_aprobacion,		 --1
	   	        _cod_reclamante,	 --2
			    _reclamante,		 --3
			    _no_documento,		 --4
			    _fecha_solicitud,	 --5
			    _fecha_autorizacion, --6
			    _autorizado_por,	 --7
			    _n_estado,     	     --8
				_diagnosticos,       --9
				_procedimientos,   	 --10
				_cod_cliente,	     --11
				_n_proveedor,		 --12
				_n_anestesia,
				_total_dias,
				_fecha_esc,
				_user_esc,
				_cod_producto,
				_n_producto,
				_n_tipo_carnet,
				_hono_medico
		   with resume;
	 
	end foreach
end if
end if
END PROCEDURE
