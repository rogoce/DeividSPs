-- Reporte Asegurado Dependiente especial Meivis
-- Creado		:  18/06/2021	- Autor: Henry Giron.
--  d_prod_sp_pro1027_dw1
 DROP procedure sp_pro1027;
 CREATE procedure "informix".sp_pro1027( a_no_documento char(20))    
	RETURNING char(20) as poliza,
			char(50) as contratante,
			char(50) as filial,
			char(5) as certif,
			char(50) as asegurado,
			char(1) as sexo,
			char(15) as estado_aseg,
			date as fch_efectiva,
			char(10) as cod_benef,
			char(50) as beneficiarios,
			char(50) as relacion,
			dec(16,2) as participacion,
			char(10) as req_tutor,
			char(50) as tutor;
   

 BEGIN

	DEFINE v_no_poliza                   	  CHAR(10);
	DEFINE v_no_documento                	  CHAR(20);
	DEFINE v_no_unidad                        CHAR(5);
	DEFINE _cod_contratante					  CHAR(10);
	define _prima                             dec(16,2);
	define _sexo, _sexo_ase		              char(1);
	define _cod_parentesco					  char(3);
	define _n_parentesco					  char(50);
	define _n_contratante					  char(50);	
	define _n_segurado					      char(50);	
	define _n_beneficiario					  char(50);		
	define _fecha_aniversario                 date;
	define _edad_cte                          integer;
	define _cod_cte                           char(10);
	define _n_producto                        char(50);
	define _fecha_ult_p                       date;
	define _n_subramo                         char(50);
	define _cod_asegurado                     char(10);
	define _estatus                           smallint;
	define _estatus_char                      char(9);
	define _estatus_uni                       smallint;
	define _estatus_uni_char                  char(15);			
	define _prima_pagada                      dec(16,2);
	define _fecha_efectiva                    date;
	define _fecha_ani_ase                     date;
	define _ced_ase                           char(30);	
	define _no_factura                        char(10);
	define _periodo                           char(7);
	define _fecha_ani_aseg,_fecha_efectiva2   date;
	define _participacion					  dec(16,2);	
	define  _null                             char(9);

drop table if exists tmp_pro1027a;

create temp table tmp_pro1027a(
	poliza        char(20), 
	contratante   char(50),
	filial        char(50),
	certif        char(5),
	asegurado     char(50),
	sexo          char(1),
	estado_aseg   char(15),
	fch_efectiva  date,	
	cod_benef     char(10),
	beneficiarios char(50),
	relacion      char(50),
	participacion dec(16,2),
	req_tutor     char(10),
	tutor         char(50)
	) with no log;	

SET ISOLATION TO DIRTY READ; 



let _null = '';
FOREACH WITH HOLD
       SELECT no_poliza,
       		  no_documento,
			  cod_contratante,
			  estatus_poliza
         INTO v_no_poliza,
         	  v_no_documento,
			  _cod_contratante,
			  _estatus
         FROM emipomae
        WHERE no_documento =  a_no_documento
		  AND actualizado = 1
		  and estatus_poliza = '1'

		let _estatus_char = '';

		if _estatus = 1 then
			let _estatus_char = 'VIGENTE';
		else
			let _estatus_char = '*';
		end if
		
		let _n_contratante = '';
		let _sexo_ase = '';		
		
		SELECT nombre
		 INTO _n_contratante
		 FROM cliclien
		WHERE cod_cliente = _cod_contratante;		


       FOREACH        
          SELECT no_unidad,
				 cod_asegurado,
				 vigencia_inic,
				 activo
            INTO v_no_unidad,
				 _cod_asegurado,
				 _fecha_efectiva,
				 _estatus_uni
            FROM emipouni
           WHERE no_poliza = v_no_poliza		   
		   
				let _n_segurado = '';
				
				SELECT nombre, sexo
				 INTO _n_segurado, _sexo_ase
				 FROM cliclien
				WHERE cod_cliente = _cod_asegurado;			   
				
				if _estatus_uni = 1 then
					let _estatus_uni_char = 'ACTIVO';		
				else
					let _estatus_uni_char =  'INACTIVO' ;
				end if				
				
				let _participacion = 0.00;	 
				let _n_beneficiario = '';
				let _n_parentesco = '';
				
			foreach
	          SELECT cod_cliente,
					 cod_parentesco,
					 benef_desde,
					 porc_partic_ben,
					 nombre
	            INTO _cod_cte,
				     _cod_parentesco,
					 _fecha_efectiva2,
					 _participacion,
					 _n_beneficiario
	            FROM emibenef
	           WHERE no_poliza = v_no_poliza
	             AND no_unidad = v_no_unidad

		       SELECT nombre
		         INTO _n_parentesco
		         FROM emiparen
		        WHERE cod_parentesco = _cod_parentesco;
				
					if _participacion is null then
						let _participacion = 0;
					end if						
				
			    INSERT INTO tmp_pro1027a(
					poliza,
					contratante,
					filial,
					certif,
					asegurado,
					sexo,
					estado_aseg,
					fch_efectiva,
					cod_benef,
					beneficiarios,
					relacion,
					participacion,
					req_tutor,
					tutor )
					
				   VALUES(
				   v_no_documento,
				   _n_contratante, _null,
				   v_no_unidad,
				   _n_segurado,
				   _sexo_ase,
				   _estatus_uni_char,
				   _fecha_efectiva2,
				   _cod_cte,
				   _n_beneficiario,
				   _n_parentesco,
				   _participacion,
				   _null,_null);									 

		    END FOREACH 

       END FOREACH 
END FOREACH
;
foreach
	select poliza,
			contratante,
			certif,
			asegurado,
			sexo,
			estado_aseg,
			fch_efectiva,
			cod_benef,
			beneficiarios,
			relacion,
			participacion
	  into  v_no_documento,
		   _n_contratante,
		   v_no_unidad,
		   _n_segurado,
		   _sexo_ase,
		   _estatus_uni_char,
		   _fecha_efectiva2,
		   _cod_cte,
		   _n_beneficiario,
		   _n_parentesco,
		   _participacion
	  from tmp_pro1027a

	 return  v_no_documento,
		   _n_contratante, _null,
		   v_no_unidad,
		   _n_segurado,
		   _sexo_ase,
		   _estatus_uni_char,
		   _fecha_efectiva2,
		   _cod_cte,
		   _n_beneficiario,
		   _n_parentesco,
		   _participacion,
		   _null,_null
	 with resume;


end foreach



END
END PROCEDURE;
