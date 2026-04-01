-- POLIZAS VIGENTES  solo salud
-- Creado    : 23/04/2014 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

   DROP procedure sp_mud03;
   CREATE procedure "informix".sp_mud03(a_cia CHAR(03),a_fecha DATE)

   RETURNING CHAR(20),varchar(50),varchar(30), varchar(10),varchar(50),varchar(50),date, date, varchar(10), varchar(50),dec(16,2),varchar(200),varchar(200), dec(16,2), dec(16,2);

    DEFINE v_descr_cia                                CHAR(50);
    DEFINE _no_documento               			      CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final           DATE;
    DEFINE v_suma_asegurada   	                      DECIMAL(16,2);
	DEFINE v_poliza                                   char(10);
	DEFINE v_cod_contratante,_cod_asegurado           char(10);
	DEFINE _cod_parentesco, _cod_dependiente           char(10);
	DEFINE v_cod_producto,v_no_unidad                 char(10);
	define _nombre_contratante, _nombre_asegurado      varchar(50);
	define _cedula                                    varchar(30);
    define _no_motor                                  varchar(30);
	define _cod_modelo                                varchar(10);   
	define _cod_marca                                 varchar(10);
	define _placa                                     varchar(10);
	define _ano_auto                                  integer;
	define _chasis                                    varchar(30);
	define _nombre_marca, _nombre_modelo, nombre_plan varchar(50);
	define _nombre_dependiente                        varchar(50);
	define _cantidad                                  smallint;
	define _cod_subramo                               varchar(3);
	define  _por_vencer, _exigible, _corriente        dec(16,2);
	define _monto30, _monto60, _monto90, _saldo       dec(16,2);
	define _suma_saldo, _monto_deducible_ase          dec(16,2);
	define _monto_deducible_dep                       dec(16,2);
	define _cod_pro, _cod_pro_de                      varchar(10);
    define _pre_aseg, _pre_depen, _con_ase,_con_depen varchar(200);

    SET ISOLATION TO DIRTY READ;

    LET v_descr_cia = sp_sis01(a_cia);
	
   --Ramo Salud
   
   foreach
     SELECT d.no_poliza, 
			d.no_documento, 
			d.cod_contratante, 
			vigencia_inic,
			vigencia_final,
			cod_subramo
	   into v_poliza, 
	        _no_documento, 
		    v_cod_contratante, 
		    v_vigencia_inic, 
		    v_vigencia_final,
			_cod_subramo
	   FROM emipomae d
      WHERE d.cod_compania    = a_cia
	    AND d.actualizado = 1
        AND estatus_poliza = 1
        AND cod_ramo = '018'
        AND (d.vigencia_final   >= a_fecha OR d.vigencia_final    IS NULL)
        AND d.fecha_suscripcion <= a_fecha
        AND d.vigencia_inic     <= a_fecha
   order by no_documento

   select cedula, 
          nombre
	 into _cedula,
		  _nombre_contratante
	 from cliclien
	where cod_cliente = v_cod_contratante;
		
		call sp_cob33('001','001',_no_documento,'2014-04',a_fecha) returning _por_vencer, _exigible, _corriente, _monto30, _monto60, _monto90, _saldo;
			if _cod_subramo = '010' then
				let _suma_saldo = _monto60 + _monto90;
					if _suma_saldo > 0 then 
						continue foreach;
					end if
			else
				let _suma_saldo = _saldo;
					if _suma_saldo > 10.00 then 
						continue foreach;
					end if
			end if
   	let _pre_depen = '';
	let _pre_aseg = '';
	let _con_ase = '';
	let _con_depen = '';
	let _monto_deducible_ase = 0;
	let _monto_deducible_dep = 0;
	    FOREACH
			select cod_producto,
			       no_unidad, 
			       suma_asegurada, 
			       cod_asegurado
			  INTO v_cod_producto, 
			  	   v_no_unidad, 
			  	   v_suma_asegurada, 
			  	   _cod_asegurado
			  from emipouni
			 where no_poliza = v_poliza
			   and activo = 1
						
			select nombre
			  into _nombre_asegurado
			  from cliclien
			 where cod_cliente = _cod_asegurado;
			
			 select nombre
			   into nombre_plan
			   from prdprod
			  where cod_producto = v_cod_producto;

					foreach 
					  select cod_procedimiento
						into _cod_pro
						from emipreas
					   where no_poliza = v_poliza
						 and no_unidad = v_no_unidad
					let _pre_aseg = '';
					 select nombre
					   into _pre_aseg
					   from emiproce
					  where cod_procedimiento = _cod_pro;

					let _con_ase = _con_ase || " " || _pre_aseg;

					end foreach	
					
				 	select monto_deducible
					  into _monto_deducible_ase
					  from recacuan
					 where no_documento = _no_documento
					   and ano = '2014'
					   and no_unidad = v_no_unidad
					   and cod_cliente = _cod_asegurado;						
			
			  select count(*)
			    into _cantidad
			    from emidepen
			   where no_poliza = v_poliza
				 and no_unidad = v_no_unidad;
		
			  if _cantidad > 0 then
					foreach					   
						select cod_cliente, 
							   cod_parentesco
						  into _cod_dependiente,
							   _cod_parentesco
						  from emidepen
						 where no_poliza = v_poliza
						   and no_unidad = v_no_unidad

						 select nombre
						   into _nombre_dependiente
						   from cliclien
						  where cod_cliente = _cod_dependiente;
						foreach
						  select cod_procedimiento
							into _cod_pro_de
							from emiprede
						   where no_poliza = v_poliza
							 and no_unidad = v_no_unidad
							 and cod_cliente = _cod_dependiente
							 let _pre_depen = ''; 

						  select nombre
						    into _pre_depen
							from emiproce
						   where cod_procedimiento = _cod_pro_de;

						let _con_depen = _con_depen || " " || _pre_depen;

						end foreach
						
						select monto_deducible
						  into _monto_deducible_dep
						  from recacuan
						 where no_documento = _no_documento
						   and ano = '2014'
						   and no_unidad = v_no_unidad
						   and cod_cliente = _cod_dependiente;	
						
				   RETURN  _no_documento, 
						   _nombre_contratante,
						   _cedula,
						   v_no_unidad,
						   _nombre_asegurado,
						   _nombre_dependiente,				    
						   v_vigencia_inic, 
						   v_vigencia_final,
						   v_cod_producto,
						   nombre_plan, 
						   v_suma_asegurada,
						   _con_ase,
						   _pre_depen,
                           _monto_deducible_ase,
						   _monto_deducible_dep WITH RESUME;
					end foreach
				else
					let _nombre_dependiente = NULL;

					RETURN _no_documento, 
						   _nombre_contratante,
						   _cedula,
						   v_no_unidad,						   
						   _nombre_asegurado,
						   _nombre_dependiente,				   
						   v_vigencia_inic, 
						   v_vigencia_final,
						   v_cod_producto,
						   nombre_plan, 
						   v_suma_asegurada,
						   _con_ase,
						   _pre_depen,
                           _monto_deducible_ase,
						   _monto_deducible_dep WITH RESUME;
		       end if
		END FOREACH
	end foreach
END PROCEDURE;
