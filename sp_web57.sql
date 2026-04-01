-- Informes de cobranzas por corredor
-- SIS v.3.3.20 - DEIVID, S.A.
-- Creado    : 19/11/2008 - Autor: Ricardo Jimenez Banda
-- Modificado para informe de corredores Federico Coronado


DROP procedure sp_web57;

CREATE procedure "informix".sp_web57(a_agente CHAR(5), a_desde DATE, a_hasta DATE )
RETURNING   VARCHAR(100) 	AS ASEGURADO,   		
			VARCHAR(30) 	as CEDULA,			
			date	    	as FECHA_NACIMIENTO,   		
			VARCHAR(1)		as SEXO, 		
			varchar(30)		as EMAIL,
			varchar(50) 	as DIRECCION,
			varchar(10)		as TELEFONO,
			--varchar(10)		as telefono2,
			--varchar(10)		as celular,
			varchar(20)     as NRO_POLIZA,
			integer			as DIA_DESDE,
			integer			as MES_DESDE,
			integer			as ANO_DESDE,
			integer			as DIA_HASTA,
			integer			as MES_HASTA,
			integer			as ANO_HASTA,
			varchar(30)     as ASEGURADORA,
			varchar(30)     as DE_RAMO,
			varchar(8)      as USUARIO_EMISOR,
			varchar(5)      as NRO_UNIDAD,
			varchar(10)     as ESTADO_VEHICULO,
			varchar(30)     as MARCA,
			varchar(30)     as MODELO,
			varchar(10)     as PLACA,
			integer         as ANO,
			dec(16,2)       as SUMA_ASEGURADA,
		    dec(16,2)       as PRIMA_BRUTA,
			dec(16,2)       as MONTO_PAGADO;	
  


	 DEFINE _cod_compania                    CHAR(3);
	 DEFINE _prima_neta                      DEC(16,2);
	 DEFINE _no_poliza                       CHAR(10);
	 DEFINE _monto							 Decimal(16,2);
	 DEFINE _no_documento                    CHAR(20);
	 DEFINE v_nombre_clte  					 CHAR(100);
	 DEFINE _cod_contratante                 CHAR(10); 
	 DEFINE v_cedula_ruc     				 CHAR(30);
	 DEFINE _tipo_produccion                 smallint;
	 DEFINE _cod_tipoprod                    CHAR(3);
	 DEFINE _nombre_ramo                     CHAR(50);
	 DEFINE _cod_ramo                        CHAR(3);
	 DEFINE _dvigencia_inic                  integer;
	 DEFINE _mvigencia_inic                  integer;
	 DEFINE _yvigencia_inic                  integer;
     DEFINE _dvigencia_final                  integer;
	 DEFINE _mvigencia_final                  integer;
	 DEFINE _yvigencia_final                  integer;
	 DEFINE _fecha_nacimiento				 DATE;
	 DEFINE _sexo							 char(1);
	 DEFINE _email							 varchar(50);
	 DEFINE _direccion1						 varchar(50);
	 DEFINE _telefono1						 varchar(10);
	 DEFINE _telefono2                       varchar(10);
	 DEFINE _celular						 varchar(10);
	 DEFINE _descr_cia                       varchar(30);
	 DEFINE _usuario						 varchar(8);
	 DEFINE _no_unidad						 varchar(5);
	 DEFINE _estado_auto					 integer;
	 DEFINE _nombre_marca					 varchar(50);
	 DEFINE _nombre_modelo					 varchar(50);
	 DEFINE _placa							 varchar(10);
	 DEFINE _ano_auto						 integer;
	 DEFINE _suma_asegurada					 dec(16,2);
	 DEFINE _prima_bruta					 dec(16,2);
	 DEFINE _nueva_renov					 char(1);
	 define _nombre                          varchar(50);
	 define _nombre_estado_auto              varchar(10);
	 define _fecha_pago                      date;
	 define _estatus_poliza					 integer;
	 define _no_unidad1                      integer;
	 define _saldo_poliza       			 dec(16,2);
	 

	 SET ISOLATION TO DIRTY READ;

	 LET _descr_cia      = " ";

	 LET _prima_neta     = 0 ;
	 let _cod_compania    = '001';
	 
	SELECT nombre
	  INTO _nombre
	  FROM agtagent    
	 WHERE cod_agente   = a_agente
	   AND cod_compania = _cod_compania;
	
	 FOREACH  
{		SELECT a.no_poliza,
		       sum(a.monto),
			   a.fecha
		  into _no_poliza,
		       _monto,
			   _fecha_pago
		  FROM  cobredet a inner join cobreagt b on a.no_remesa = b.no_remesa
		 WHERE a.fecha BETWEEN a_desde AND a_hasta
		   AND a.actualizado  = 1
           AND a.tipo_mov     in ("P", "N")
           and a.renglon = b.renglon
           and b.cod_agente = a_agente
      group by 1,3
}
		   select c.nombre,								 
		          cedula,                                
				  fecha_aniversario,                     
				  sexo,                                  
				  e_mail,                                
				  direccion_1,                           
				  telefono1,                             
				  telefono2,                             
				  celular,                               
				  no_documento,                          
				  day(a.vigencia_inic),
				  month(a.vigencia_inic),	
				  year(a.vigencia_inic),				  
				  day(a.vigencia_final),
				  month(a.vigencia_final),
				  year(a.vigencia_final),
				  d.nombre,                              
				  a.user_added,                          
				  e.no_unidad,                           
				  nuevo,                                 
				  h.nombre,                              
				  i.nombre,                              
				  placa,                                 
				  ano_auto,                              
				  a.suma_asegurada,                      
				  a.prima_bruta,                         
				  a.cod_tipoprod,                        
				  a.cod_ramo,                            
				  a.nueva_renov,
				  estatus_poliza,
				  a.no_poliza
			 into v_nombre_clte,
				  v_cedula_ruc,
				  _fecha_nacimiento,
				  _sexo,
				  _email,
				  _direccion1,
				  _telefono1,
				  _telefono2,
				  _celular,
				  _no_documento,
				  _dvigencia_inic,
				  _mvigencia_inic,
				  _yvigencia_inic,
				  _dvigencia_final,
				  _mvigencia_final,
				  _yvigencia_final,
				  _nombre_ramo,
				  _usuario,
				  _no_unidad,
				  _estado_auto,
				  _nombre_marca,
				  _nombre_modelo,
				  _placa,
				  _ano_auto,
				  _suma_asegurada,
				  _prima_bruta,
				  _cod_tipoprod,
				  _cod_ramo,
				  _nueva_renov,
				  _estatus_poliza,
				  _no_poliza
			 from emipomae a inner join emipoagt b on a.no_poliza = b.no_poliza
			inner join cliclien c on a.cod_contratante = c.cod_cliente
			inner join prdramo d on a.cod_ramo = d.cod_ramo
			inner join emipouni e on a.no_poliza = e.no_poliza
			inner join emiauto f on a.no_poliza = f.no_poliza
			inner join emivehic g on g.no_motor = f.no_motor
			inner join emimarca h on h.cod_marca = g.cod_marca
			inner join emimodel i on i.cod_modelo = g.cod_modelo
			where b.cod_agente = a_agente
			and a.fecha_suscripcion BETWEEN a_desde AND a_hasta
			and a.actualizado = 1
			and f.no_unidad = e.no_unidad
			--and nueva_renov = 'N'	   

		SELECT tipo_produccion
		  INTO _tipo_produccion
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;

		-- Si es coaseguro minoritario no va
		if _tipo_produccion = 3 then
			continue foreach;
		end if
		
	{	if _nueva_renov = 'R' then
			continue foreach;
		end if
	}
        IF _cod_ramo IS NULL OR _cod_ramo = " " THEN
           CONTINUE FOREACH;
        END IF
	
		if _cod_ramo = '020' then
			let _saldo_poliza =  sp_cob174(_no_documento);
			if _saldo_poliza > 0 then
				-- monto es monto pagado; es 0 porque las soda son un solo pago. y si tiene saldo es porque no se a pagado.
				let _monto = 0;
			else
				SELECT sum(a.monto)
				  into _monto
				  FROM  cobredet a inner join cobreagt b on a.no_remesa = b.no_remesa
				 WHERE a.doc_remesa 	= _no_documento
				   AND a.actualizado  	= 1
				   AND a.tipo_mov     	in ("P", "N")
				   and a.renglon 		= b.renglon
				   and b.cod_agente		= a_agente;	
				   
				--let _monto = _monto - _prima_bruta;
				
			end if
		else
			SELECT sum(a.monto)
			  into _monto
			  FROM  cobredet a inner join cobreagt b on a.no_remesa = b.no_remesa
			 WHERE a.doc_remesa 	= _no_documento
			   and a.no_poliza 		= _no_poliza
			   AND a.actualizado  	= 1
			   AND a.tipo_mov     	in ("P", "N")
			   and a.renglon 		= b.renglon
			   and b.cod_agente		= a_agente;	
		end if
		
		IF _monto IS NULL OR _monto = " " THEN
			let _monto = 0.00;	
		END IF
		
		IF _estatus_poliza <> 1 THEN
           CONTINUE FOREACH;
        END IF
		
		if _estado_auto = 1 then
			let _nombre_estado_auto = 'NUEVO';
		else
			let _nombre_estado_auto = 'USADO';
		end if

        LET _descr_cia = sp_sis01(_cod_compania);
		
		let _nombre_ramo = "AUTOMOVIL INDIVIDUAL";
		
		let _no_unidad1  = _no_unidad;
		
		RETURN v_nombre_clte,
               v_cedula_ruc,
               _fecha_nacimiento,
               _sexo,
               _email,
               _direccion1,
               _telefono1,
               --_telefono2,
               --_celular,
               _no_documento,
			   _dvigencia_inic,
			   _mvigencia_inic,
			   _yvigencia_inic,
			   _dvigencia_final,
			   _mvigencia_final,
			   _yvigencia_final,
			   _descr_cia,
               _nombre_ramo,
               _usuario,
               _no_unidad1,
               _nombre_estado_auto,
               _nombre_marca,
               _nombre_modelo,
               _placa,
               _ano_auto,
               _suma_asegurada,
               _prima_bruta,
			   _monto WITH RESUME;
		
	  END FOREACH
   		
END PROCEDURE