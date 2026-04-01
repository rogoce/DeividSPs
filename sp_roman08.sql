--***********************************************************************
-- Procedimiento que genera proyecto de recuperacion de cartera 2024
--***********************************************************************
-- Creado    : 09/04/2024 - Autor: Armando Moreno M.

DROP PROCEDURE sp_roman08;
CREATE PROCEDURE sp_roman08()
RETURNING smallint,char(10),char(20),char(3),char(50),char(3),char(50),date,date,date,char(50),char(5),char(50),char(50),char(30),char(30),char(30),
		  char(50),date,char(5),char(50),char(5),char(50),smallint, DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),char(5),char(50);

DEFINE _no_poliza,_no_reclamo,_cod_contratante                 						CHAR(10);
DEFINE _fecha_cancela,_fecha_aniv,_vigen_ini,_vigencia_final   						DATE;
DEFINE _nombre,_n_tipo_can,_n_marca,_n_modelo,_n_manzana,_nombre_ramo,_n_producto   CHAR(50); 
DEFINE _no_documento    															CHAR(20); 
DEFINE _e_mail,_tel1,_celular,_no_motor    											CHAR(30); 
DEFINE _ano_auto,_tipo_incendio        												SMALLINT;
DEFINE _cod_ramo,_cod_subramo,_cod_tipocan        									CHAR(3);  
DEFINE _cod_producto,_no_unidad,_cod_modelo,_cod_marca								char(5);
define _nombre_subramo																char(50);
define _n_tipo_inc	    															char(17);
define _cod_manzana																	char(15);
define _sini_incurrido,_sini_inc,_prima_neta,_prima_bruta,_suma        				decimal(16,2);

--SET DEBUG FILE TO "sp_pro868a.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

--*********************************
-- Polizas Vencidas 2023 Ramo Auto
--*********************************
foreach
	select no_documento
	  into _no_documento
	  from emipomae emi
	 where actualizado    = 1
	   and ((estatus_poliza = 3 and vigencia_final >= '01/01/2023' and vigencia_final <= '31/12/2023' and renovada = 0) or (fecha_cancelacion between '01/01/2023' and '31/12/2023'))
	   and cod_ramo in('002','020','023')
	 group by no_documento
	 order by no_documento

	let _no_poliza = sp_sis21(_no_documento);
	
	--siniestros incurridos
	let _sini_inc = 0;
	let _sini_incurrido =0;
	
	foreach
		select no_reclamo
		  into _no_reclamo
		  from recrcmae
		 where no_poliza = _no_poliza 
		
		let _sini_inc = sp_roman09(_no_reclamo);
		let _sini_incurrido = _sini_incurrido + _sini_inc;
		
	end foreach
	
	select no_documento,
		   cod_contratante,
		   cod_ramo,
		   cod_subramo,
		   vigencia_inic,
		   vigencia_final,
		   prima_neta,
		   prima_bruta,
		   fecha_cancelacion
	  into _no_documento,
		   _cod_contratante,
		   _cod_ramo,
		   _cod_subramo,
		   _vigen_ini,
		   _vigencia_final,
		   _prima_neta,
		   _prima_bruta,
		   _fecha_cancela
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select nombre
      into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	  
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;
	 
	select fecha_aniversario,
	       e_mail,
		   nombre,
		   telefono1,
		   celular
	  into _fecha_aniv,
           _e_mail,
           _nombre,
           _tel1,
		   _celular
      from cliclien
	 where cod_cliente = _cod_contratante; 
	 
	foreach
		select no_unidad,
		       suma_asegurada,
			   cod_producto
	      into _no_unidad,
		       _suma,
			   _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza

		select no_motor
		  into _no_motor
		  from emiauto
		 where no_poliza = _no_poliza
           and no_unidad = _no_unidad;

		select cod_marca,
		       cod_modelo,
			   ano_auto
		  into _cod_marca,
               _cod_modelo,
               _ano_auto
          from emivehic
         where no_motor = _no_motor;
		 
		select nombre into _n_marca from emimarca
		where cod_marca = _cod_marca;
		
		select nombre into _n_modelo from emimodel
		where cod_marca  = _cod_marca
		  and cod_modelo = _cod_modelo;
		  
		select nombre
		  into _n_producto
          from prdprod
         where cod_producto = _cod_producto;
		  
		return 3,_no_poliza,_no_documento,_cod_ramo,_nombre_ramo,_cod_subramo,_nombre_subramo,_fecha_cancela,_vigen_ini,_vigencia_final,'',_no_unidad,'',_nombre,
		       _tel1,_celular,_e_mail,'',_fecha_aniv,_cod_marca,_n_marca,_cod_modelo,_n_modelo,_ano_auto,_suma,_prima_neta,_prima_bruta,_sini_incurrido,
			   _cod_producto,_n_producto with resume;
	end foreach
end foreach
--*********************************************
-- Polizas Canceladas 2023 Ramos Patrimoniales
--*********************************************
foreach
	select no_documento
	  into _no_documento
	  from emipomae
	 where actualizado    = 1
	   and ((fecha_cancelacion between '01/01/2023' and '31/12/2023') or (estatus_poliza = 3 and vigencia_final >= '01/01/2023' and vigencia_final <= '31/12/2023' and renovada = 0))
	   and cod_ramo in('001','003','005','006','007','009','010','011','012','013','014','015','017','021','022','024','025')
	 group by no_documento
	 order by no_documento

	let _no_poliza = sp_sis21(_no_documento);
	
	--siniestros incurridos
	let _sini_inc = 0;
	let _sini_incurrido =0;
	
	foreach
		select no_reclamo
		  into _no_reclamo
		  from recrcmae
		 where no_poliza = _no_poliza 
		
		let _sini_inc = sp_roman09(_no_reclamo);
		let _sini_incurrido = _sini_incurrido + _sini_inc;
		
	end foreach
	
	--Motivo de cancelacion
	foreach
		select cod_tipocan
		  into _cod_tipocan
		  from endedmae
		 where actualizado = 1
		   and no_poliza = _no_poliza
		   and cod_endomov = '002'		--cancelacion
		 order by no_endoso desc
		   
		select nombre 
		  into _n_tipo_can 
		  from endtican
		where cod_tipocan = _cod_tipocan;
		
		exit foreach;
		
	end foreach
	
	select no_documento,
		   cod_contratante,
		   cod_ramo,
		   cod_subramo,
		   vigencia_inic,
		   vigencia_final,
		   prima_neta,
		   prima_bruta,
		   fecha_cancelacion
	  into _no_documento,
		   _cod_contratante,
		   _cod_ramo,
		   _cod_subramo,
		   _vigen_ini,
		   _vigencia_final,
		   _prima_neta,
		   _prima_bruta,
		   _fecha_cancela
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select nombre
      into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	  
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;
	 
	select fecha_aniversario,
	       e_mail,
		   nombre,
		   telefono1,
		   celular
	  into _fecha_aniv,
           _e_mail,
           _nombre,
           _tel1,
		   _celular
      from cliclien
	 where cod_cliente = _cod_contratante; 
	 
	foreach
		select no_unidad,
		       suma_asegurada,
			   tipo_incendio,
			   cod_manzana,
			   cod_producto
	      into _no_unidad,
		       _suma,
			   _tipo_incendio,
			   _cod_manzana,
			   _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza
		 
		if _tipo_incendio = 1 then
			let _n_tipo_inc = 'Edificio';
		elif _tipo_incendio = 2 then
			let _n_tipo_inc = 'Contenido';
		elif _tipo_incendio = 3 then
			let _n_tipo_inc = 'Lucro Cesante';
		else
			let _n_tipo_inc = 'Perdida de Renta';
		end if

		select referencia
		  into _n_manzana
		  from emiman05
		 where cod_manzana = _cod_manzana;

		select nombre
		  into _n_producto
          from prdprod
         where cod_producto = _cod_producto;
		 
		return 2,_no_poliza,_no_documento,_cod_ramo,_nombre_ramo,_cod_subramo,_nombre_subramo,_fecha_cancela,_vigen_ini,_vigencia_final,_n_tipo_can,_no_unidad,_n_tipo_inc,_nombre,
		       _tel1,_celular,_e_mail,_n_manzana,_fecha_aniv,'','','','',0,_suma,_prima_neta,_prima_bruta,_sini_incurrido,_cod_producto,_n_producto with resume;
	end foreach
	
end foreach

END PROCEDURE;