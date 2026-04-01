-- Procedimiento que Prepara la Información de los Reclamos de la Carga de Pma Asistencias
-- creado 24/01/2014 Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web76;	

CREATE PROCEDURE sp_web76(a_aprob char(10))

returning char(10),
		  char(10),	
		  char(100),  
		  char(10),	
		  char(100),	
		  smallint,	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  decimal(16,2), 
		  decimal(16,2), 
		  smallint,	   
		  decimal(5,2),  
		  decimal(5,2),  
		  integer,	   
		  decimal(16,2), 
		  decimal(5,2),  
		  decimal(16,2), 
		  decimal(5,2),  
		  decimal(16,2), 
		  decimal(5,2),  
		  decimal(16,2), 
		  decimal(5,2),
		  char(255),
		  datetime year to fraction(5),
		  smallint, 					 
		  char(30),
  		  decimal(5,2),
		  decimal(5,2),
		  decimal(16,2),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(20),
		  varchar(255),
		  decimal(5,2),
		  decimal(5,2),
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),	
		  char(10),
          char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(255),
		  char(5),
		  varchar(255),
		  varchar(255),
		  varchar(100);

define _no_aprobacion	     char(10);						--1 -- A.   N£mero de Certificado
define _cod_reclamante	     char(10);						--2 -- 1.   Cod  del Paciente
define _reclamante,_n_aseg_prin      char(100);                     --3 -- 1.1  Nombre del Reclamante
define _cod_hospital,_cod_asegurado  char(10);						--4 -- 2	Cod	del Cliente	Hospital/Proveedor
define _hospital	         char(100);						--5 -- 2.1	Nombre del Cliente Hospital/Proveedor
define _tipo_procedimiento   smallint;						--6 -- 3.   Tipo de Procedimiento
define _cod_icd1             char(10);					    --7 -- 4.1  Diag 1
define _cod_icd2             char(10);						--8 -- 4.2  Diag 2
define _cod_icd3             char(10);						--9 -- 4.3  Diag 3
define _cod_icd4             char(10);						--10-- 4.4  Diag 4
define _cod_icd5             char(10);						--11-- 4.5  Diag 5
define _cod_cpt1             char(10);						--12-- 5.1  Procedimientos 1
define _cod_cpt2             char(10);						--13-- 5.2  Procedimientos 2
define _cod_cpt3             char(10);						--14-- 5.3  Procedimientos 3
define _cod_cpt4             char(10);						--15-- 5.4  Procedimientos 4
define _cod_cpt5             char(10);						--16-- 5.5  Procedimientos 5
define _co_pago              decimal(16,2);	  				--17-- 6.   Co-Pago
define _deducible            decimal(16,2);					--18-- 7.   Deducible
define _tipo_hab             smallint;						--19-- 8.   Tipo de Habitaci¢n
define _porc_aprob_hab       decimal(5,2);					--20-- 8.2  Por de hab
define _porc_gastos_hospit   decimal(5,2);                  --21-- 9    Porcentaje en gastos de hosp
define _total_dias           integer;	         		    --22-- 10.  Total de Dias autorizados
define _atencion_medica      decimal(16,2);					--23-- 11.  Atenci¢n M‚dica 
define _porc_atencion_medi   decimal(5,2);					--24-- 11.1 Porcentaje Atenci¢n M‚dica
define _cirujano             decimal(16,2);                 --25-- 12   Cirujano
define _porc_cirujano        decimal(5,2); 	  				--26-- 12.1 Porc. de Cirujano
define _anesteciologo        decimal(16,2);					--27-- 13.	Anestesiologo
define _porc_anesteciologo   decimal(5,2);					--28-- 13.1	Porc. Anestesiologo
define _pediatra             decimal(16,2);					--29-- 14   Pediatra
define _porc_pediatra        decimal(5,2);					--30-- 14.1 Por de Pediatra
define _comentario           char(255);		  			    --31-- 15   Cometarios
define _fecha_autorizacion   datetime year to fraction(5);  --32-- 16   Fecha de autorazaci¢n
define _estado               smallint; 						--33-- 17 	Estado 
define _autorizado_por       char(10);						--34-- 18   Registrado por	
define _no_documento	     char(20);
define _producto             char(50);
define _porc_copago          decimal(5,2);                 --25-- 12   Cirujano
define _porc_ded             decimal(5,2); 	  				--26-- 12.1 Porc. de Cirujano
define _costo_hab            decimal(16,2);					--27-- 13.	Anestesiologo
define _n_icd1				 char(255);
define _n_icd2				 char(255);
define _n_icd3				 char(255);
define _n_icd4				 char(255);
define _n_icd5				 char(255);
define _n_cpt1				 char(255);
define _n_cpt2				 char(255);
define _n_cpt3				 char(255);
define _n_cpt4				 char(255);
define _n_cpt5				 char(255);
define _n_usuario            char(30);
define _comentario2          varchar(255);
define _porc_hono_medico      decimal(5,2);
define _porc_gasto_fuera_hosp decimal(5,2);
define _n_icd6				 char(255);
define _n_icd7				 char(255);
define _n_icd8				 char(255);
define _n_icd9				 char(255);
define _n_icd10				 char(255);
define _n_cpt6				 char(255);
define _n_cpt7				 char(255);
define _n_cpt8				 char(255);
define _n_cpt9				 char(255);
define _n_cpt10				 char(255);
define _cod_icd6             char(10);					    --7 -- 9.6  Diag 6
define _cod_icd7             char(10);						--8 -- 9.7  Diag 7
define _cod_icd8             char(10);						--9 -- 9.8  Diag 8
define _cod_icd9             char(10);						--60-- 9.9  Diag 9
define _cod_icd10             char(10);						--66-- 9.10  Diag 10
define _cod_cpt6             char(10);						--67-- 10.6  Procedimientos 6
define _cod_cpt7             char(10);						--68-- 10.7  Procedimientos 7
define _cod_cpt8             char(10);						--69-- 10.8  Procedimientos 8
define _cod_cpt9             char(10);						--610-- 10.9  Procedimientos 9
define _cod_cpt10            char(10);						--66-- 10.10  Procedimientos 10
define _no_poliza			 char(10);
define _no_unidad 			 char(5);
define _cod_producto		 char(5);
define _cont                 smallint;
define _observacion          varchar(255);
define _observacion1          varchar(255);

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rec148.trc";
--trace on;
   foreach
		SELECT  no_aprobacion,      		 --	 1
			    cod_reclamante,				 --	 2
				cod_cliente, 				 --	 4
			    tipo_procedimiento,			 --	 6
				cod_icd1,					 --	 7
				cod_icd2,					 --	 8
				cod_icd3,					 --	 9
				cod_icd4,					 --	 10
				cod_icd5,					 --	 11
				cod_cpt1,					 --	 12
				cod_cpt2,					 --	 13
				cod_cpt3,					 --	 14
				cod_cpt4,					 --	 15
				cod_cpt5,					 --	 16
			    co_pago,					 --	 17
			    deducible,					 --	 18
				tipo_hab,					 --	 19
				porc_aprob_hab,				 --	 20
				total_dias,         		 --	 22
				atencion_medica,    		 --	 23
				porc_atencion_medica, 		 --	 24
				cirujano,           		 --	 25
				porc_cirujano,      		 --	 26
				anesteciologo,    			 --	 27
				porc_anesteciologo,			 --	 28 
				pediatra,          			 --	 29
				porc_pediatra,      		 --	 30
				comentario,         		 --	 31
				fecha_autorizacion, 		 --	 32
				estado,             		 --	 33
				autorizado_por,
				porc_gastos_hospital,
				porc_copago,
				porc_ded,
				costo_hab,
				no_documento,
				comentario2,
				porc_hono_medico,
				porc_gasto_fuera_hosp,
				cod_icd6,					--	 7
				cod_icd7,					--	 8
				cod_icd8,					--	 9
				cod_icd9,					--	60
				cod_icd10,					--	66 
				cod_cpt6,					--	67
				cod_cpt7,					--	68
				cod_cpt8,					--	69
				cod_cpt9,					--	610
				cod_cpt10,					--	66
				observacion,
				observacion1
		  INTO  _no_aprobacion,      		 --	 1
			    _cod_reclamante,   			 --	 2
				_cod_hospital,				 --	 4
			    _tipo_procedimiento,		 --	 6
				_cod_icd1,					 --	 7
				_cod_icd2,					 --	 8
				_cod_icd3,					 --	 9
				_cod_icd4,					 --	10
				_cod_icd5,					 --	11 
				_cod_cpt1,					 --	12
				_cod_cpt2,					 --	13
				_cod_cpt3,					 --	14
				_cod_cpt4,					 --	15
				_cod_cpt5,					 --	16
			    _co_pago,					 --	17
			    _deducible,					 --	18
				_tipo_hab,					 --	19
				_porc_aprob_hab,     		 --	20
				_total_dias,         		 --	22
				_atencion_medica,    		 --	23
				_porc_atencion_medi, 		 --	24
				_cirujano,           		 --	25
				_porc_cirujano,      		 --	26
				_anesteciologo,    			 --	27
				_porc_anesteciologo,		 --	28
				_pediatra,          		 --	29
				_porc_pediatra,      		 --	30
				_comentario,         		 --	31
				_fecha_autorizacion, 		 --	32
				_estado,             		 --	33
				_autorizado_por,
				_porc_gastos_hospit,
				_porc_copago,
				_porc_ded,
				_costo_hab,
				_no_documento,
				_comentario2,
				_porc_hono_medico,
				_porc_gasto_fuera_hosp,
				_cod_icd6,					--	 7
				_cod_icd7,					--	 8
				_cod_icd8,					--	 9
				_cod_icd9,					--	60
				_cod_icd10,					--	66 
				_cod_cpt6,					--	67
				_cod_cpt7,					--	68
				_cod_cpt8,					--	69
				_cod_cpt9,					--	610
				_cod_cpt10,					--	66
				_observacion,
				_observacion1
	       FROM recprea1			             
	      WHERE no_aprobacion = a_aprob

		 SELECT descripcion
		   INTO _n_usuario
		   FROM insuser
		  WHERE usuario = _autorizado_por;

		 SELECT nombre
		   INTO _hospital
		   FROM cliclien
		  WHERE cod_cliente = _cod_hospital;

	   	 SELECT nombre
		   INTO _reclamante
		   FROM cliclien
		  WHERE cod_cliente = _cod_reclamante;

		 if _comentario2 is null then
			let _comentario2 = "";
		 end if
		 if _observacion is null then
			let _observacion = "";
		 end if
		 if _observacion1 is null then
			let _observacion1 = "";
		 end if
		 
		 if _cod_icd1 is not null or _cod_icd1 <> "" then
		   	 SELECT nombre
			   INTO _n_icd1
			   FROM recicd
			  WHERE cod_icd = _cod_icd1;
			  let _n_icd1 = trim(_n_icd1);
		 else
			let _n_icd1 = "";
		 end if
		 if _cod_icd2 is not null or _cod_icd2 <> "" then
		   	 SELECT nombre
			   INTO _n_icd2
			   FROM recicd
			  WHERE cod_icd = _cod_icd2;
			  let _n_icd2 = trim(_n_icd2);
		 else
			let _n_icd2 = "";
		 end if
		 if _cod_icd3 is not null or _cod_icd3 <> "" then
		   	 SELECT nombre
			   INTO _n_icd3
			   FROM recicd
			  WHERE cod_icd = _cod_icd3;
			  let _n_icd3 = trim(_n_icd3);
		 else
			let _n_icd3 = "";
		 end if
		 if _cod_icd4 is not null or _cod_icd4 <> "" then
		   	 SELECT nombre
			   INTO _n_icd4
			   FROM recicd
			  WHERE cod_icd = _cod_icd4;
			  let _n_icd4 = trim(_n_icd4);
		 else
			let _n_icd4 = "";
		 end if
		 if _cod_icd5 is not null or _cod_icd5 <> "" then
		   	 SELECT nombre
			   INTO _n_icd5
			   FROM recicd
			  WHERE cod_icd = _cod_icd5;
			  let _n_icd5 = trim(_n_icd5);
		 else
			let _n_icd5 = "";
		 end if

		 if _cod_cpt1 is not null or _cod_cpt1 <> "" then
		   	 SELECT nombre
			   INTO _n_cpt1
			   FROM reccpt
			  WHERE cod_cpt = _cod_cpt1;
			  let _n_cpt1 = trim(_n_cpt1);
		 else
			let _n_cpt1 = "";
		 end if
		 if _cod_cpt2 is not null or _cod_cpt2 <> "" then
		   	 SELECT nombre
			   INTO _n_cpt2
			   FROM reccpt
			  WHERE cod_cpt = _cod_cpt2;
			  let _n_cpt2 = trim(_n_cpt2);
		 else
			let _n_cpt2 = "";
		 end if
		 if _cod_cpt3 is not null or _cod_cpt3 <> "" then
		   	 SELECT nombre
			   INTO _n_cpt3
			   FROM reccpt
			  WHERE cod_cpt = _cod_cpt3;
			  let _n_cpt3 = trim(_n_cpt3);
		 else
			let _n_cpt3 = "";
		 end if
		 if _cod_cpt4 is not null or _cod_cpt4 <> "" then
		   	 SELECT nombre
			   INTO _n_cpt4
			   FROM reccpt
			  WHERE cod_cpt = _cod_cpt4;
			  let _n_cpt4 = trim(_n_cpt4);
		 else
			let _n_cpt4 = "";
		 end if
		 if _cod_cpt5 is not null or _cod_cpt5 <> "" then
		   	 SELECT nombre
			   INTO _n_cpt5
			   FROM reccpt
			  WHERE cod_cpt = _cod_cpt5;
			  let _n_cpt5 = trim(_n_cpt5);
		 else
			let _n_cpt5 = "";
		 end if
		 
		 if _cod_icd6 is not null or _cod_icd6 <> "" then
		   	 SELECT nombre
			   INTO _n_icd6
			   FROM recicd
			  WHERE cod_icd = _cod_icd6;
			  let _n_icd6 = trim(_n_icd6);
		 else
			let _n_icd6 = "";
		 end if
		 if _cod_icd7 is not null or _cod_icd7 <> "" then
		   	 SELECT nombre
			   INTO _n_icd7
			   FROM recicd
			  WHERE cod_icd = _cod_icd7;
			  let _n_icd7 = trim(_n_icd7);
		 else
			let _n_icd7 = "";
		 end if
		 if _cod_icd8 is not null or _cod_icd8 <> "" then
		   	 SELECT nombre
			   INTO _n_icd8
			   FROM recicd
			  WHERE cod_icd = _cod_icd8;
			  let _n_icd8 = trim(_n_icd8);
		 else
			let _n_icd8 = "";
		 end if
		 if _cod_icd9 is not null or _cod_icd9 <> "" then
		   	 SELECT nombre
			   INTO _n_icd9
			   FROM recicd
			  WHERE cod_icd = _cod_icd9;
			  let _n_icd9 = trim(_n_icd9);
		 else
			let _n_icd9 = "";
		 end if
		 if _cod_icd10 is not null or _cod_icd10 <> "" then
		   	 SELECT nombre
			   INTO _n_icd10
			   FROM recicd
			  WHERE cod_icd = _cod_icd10;
			  let _n_icd10 = trim(_n_icd10);
		 else
			let _n_icd10 = "";
		 end if

		 if _cod_cpt6 is not null or _cod_cpt6 <> "" then
		   	 SELECT nombre
			   INTO _n_cpt6
			   FROM reccpt
			  WHERE cod_cpt = _cod_cpt6;
			  let _n_cpt6 = trim(_n_cpt6);
		 else
			let _n_cpt6 = "";
		 end if
		 if _cod_cpt7 is not null or _cod_cpt7 <> "" then
		   	 SELECT nombre
			   INTO _n_cpt7
			   FROM reccpt
			  WHERE cod_cpt = _cod_cpt7;
			  let _n_cpt7 = trim(_n_cpt7);
		 else
			let _n_cpt7 = "";
		 end if
		 if _cod_cpt8 is not null or _cod_cpt8 <> "" then
		   	 SELECT nombre
			   INTO _n_cpt8
			   FROM reccpt
			  WHERE cod_cpt = _cod_cpt8;
			  let _n_cpt8 = trim(_n_cpt8);
		 else
			let _n_cpt8 = "";
		 end if
		 if _cod_cpt9 is not null or _cod_cpt9 <> "" then
		   	 SELECT nombre
			   INTO _n_cpt9
			   FROM reccpt
			  WHERE cod_cpt = _cod_cpt9;
			  let _n_cpt9 = trim(_n_cpt9);
		 else
			let _n_cpt9 = "";
		 end if
		 if _cod_cpt10 is not null or _cod_cpt10 <> "" then
		   	 SELECT nombre
			   INTO _n_cpt10
			   FROM reccpt
			  WHERE cod_cpt = _cod_cpt10;
			  let _n_cpt10 = trim(_n_cpt10);
		 else
			let _n_cpt10 = "";
		 end if		 

		 let _n_usuario = trim(_n_usuario);
		 
		 call sp_sis21(_no_documento) returning _no_poliza;
		 
		 let _cont = 0;
		 
		 select count(*)
		   into _cont
			from emipouni 
		   where no_poliza 		= _no_poliza
			 and cod_asegurado 	= _cod_reclamante;
			 
		 if _cont is null then
			let _cont = 0;
         end if		
		 
		 if _cont > 1 then
			 select cod_producto, 
					no_unidad 
			   into _cod_producto,
					_no_unidad
				from emipouni 
			   where no_poliza 		= _no_poliza
				 and cod_asegurado 	= _cod_reclamante
				 and activo = 1;
		 else
			 select cod_producto, 
					no_unidad 
			   into _cod_producto,
					_no_unidad
				from emipouni 
			   where no_poliza 		= _no_poliza
				 and cod_asegurado 	= _cod_reclamante;
		 end if
		 
		if _no_unidad is null then
			foreach
				select no_unidad
				  into _no_unidad
				  from emidepen
				 where no_poliza = _no_poliza
				   and cod_cliente = _cod_reclamante
				   
				exit foreach;
			end foreach	
		end if
		select cod_asegurado
		  into _cod_asegurado
 		  from emipouni 
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
		   
		SELECT nombre
		  INTO _n_aseg_prin
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;
		 
	     return _no_aprobacion,      		--	 1
			    _cod_reclamante,   			--	 2
				_reclamante, 	            --	 3
				_cod_hospital,				--	 4
				_hospital,		            --   5
			    _tipo_procedimiento,		--	 6
				_cod_icd1,					--	 7
				_cod_icd2,					--	 8
				_cod_icd3,					--	 9
				_cod_icd4,					--	10
				_cod_icd5,					--	11 
				_cod_cpt1,					--	12
				_cod_cpt2,					--	13
				_cod_cpt3,					--	14
				_cod_cpt4,					--	15
				_cod_cpt5,					--	16
			    _co_pago,					--	17
			    _deducible,					--	18
				_tipo_hab,					--	19
				_porc_aprob_hab,     		--	20
				_porc_gastos_hospit,        --  21
				_total_dias,         		--	22
				_atencion_medica,    		--	23
				_porc_atencion_medi, 		--	24
				_cirujano,           		--	25
				_porc_cirujano,      		--	26
				_anesteciologo,    			--	27
				_porc_anesteciologo,		--	28
				_pediatra,          		--	29
				_porc_pediatra,      		--	30
				_comentario,         		--	31
				_fecha_autorizacion, 		--	32
				_estado,             		--	33
				_n_usuario,
				_porc_copago,
				_porc_ded,
				_costo_hab,
				_n_icd1,
				_n_icd2,
				_n_icd3,
				_n_icd4,
				_n_icd5,
				_n_cpt1,
				_n_cpt2,
				_n_cpt3,
				_n_cpt4,
				_n_cpt5,
				_no_documento,
				_comentario2,
				_porc_hono_medico,			--50
				_porc_gasto_fuera_hosp,
				_cod_icd6,					--	 7
				_cod_icd7,					--	 8
				_cod_icd8,					--	 9
				_cod_icd9,					--	60
				_cod_icd10,					--	66 
				_cod_cpt6,					--	67
				_cod_cpt7,					--	68
				_cod_cpt8,					--	69
				_cod_cpt9,					--	610
				_cod_cpt10,					--	66
				_n_icd6,
				_n_icd7,
				_n_icd8,
				_n_icd9,
				_n_icd10,
				_n_cpt6,
				_n_cpt7,
				_n_cpt8,
				_n_cpt9,
				_n_cpt10,
				_no_unidad,
				_observacion,
				_observacion1,
				_n_aseg_prin
		   with resume;				 
	end foreach

END PROCEDURE
                                                                                                                                                     
