-- Informes de Detalle de Endosos por Periodo
-- Creado    : 22/03/2012 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_pro359;
create procedure sp_pro359(
			a_compania	char(3),
			a_agencia	char(3),
			a_periodo1	char(7),
			a_periodo2	char(7)
			)
returning	char(20), 		--1_documento
			date,			--2_vig_ini
			date,			--3_vig_fin
			char(5),		--4_no_unidad
			char(5),		--5_no_endoso
			varchar(50),	--6_asegurado
			char(5),		--7_cod_contrato
			varchar(50),	--8_desc_contrato
			date,			--9_vig_ini_contr
			date;			--10_vig_fin_contr	   	

begin
									  
define _desc_contrato		varchar(50);
define _desc_unidad			varchar(50);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _vig_ini				date;
define _vig_fin				date;
define _vig_ini_contr		date;
define _vig_fin_contr		date;
define _suma_asegurada		decimal(16,2);
	  	  	  	
set isolation to dirty read;

--SET DEBUG FILE TO "sp_pro359.trc"; 
--trace on;

CREATE TEMP TABLE tmp_endosos
               (no_documento	char(20),
			    vigencia_ini	date,
				vigencia_fin	date,
                no_unidad		char(5),
				no_endoso		char(5),
                desc_unidad		varchar(50),
				cod_contrato	char(5),
				desc_contrato	varchar(50),
				vig_ini_contr	date,
				vig_fin_contr	date, --)WITH NO LOG;
            PRIMARY KEY(no_documento, no_endoso, no_unidad, cod_contrato)) WITH NO LOG;

foreach
	select no_poliza,
		   no_endoso
	  into _no_poliza,
		   _no_endoso
	  from endedmae
	 where periodo between a_periodo1 and a_periodo2
	 order by no_poliza,no_endoso

	select no_documento,
		   vigencia_inic,																  
		   vigencia_final																  
	  into _no_documento,																  
	  	   _vig_ini,																	  
	  	   _vig_fin	 																	  
	  from emipomae																		  
	 where no_poliza = _no_poliza;														  
																						  
	foreach																				  
		select distinct no_unidad,																  
			   cod_contrato
		  into _no_unidad,
			   _cod_contrato
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso

		select nombre,
			   vigencia_inic,
			   vigencia_final
		  into _desc_contrato,
		  	   _vig_ini_contr,
			   _vig_fin_contr
		  from reacomae
		 where cod_contrato = _cod_contrato;
		 
		 select desc_unidad
		   into _desc_unidad
		   from emipouni
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad;


		begin
			on exception in(-239)
		    	  
			end exception

			insert into tmp_endosos(no_documento,
									vigencia_ini,
									vigencia_fin,
									no_unidad,
									no_endoso,
									desc_unidad,
									cod_contrato,
									desc_contrato,
									vig_ini_contr,
									vig_fin_contr
								   )
							 values(_no_documento,
									_vig_ini,
									_vig_fin,
									_no_unidad,
									_no_endoso,
									_desc_unidad,
									_cod_contrato,
									_desc_contrato,
									_vig_ini_contr,
									_vig_fin_contr
								   );				 
		end		
	end foreach
end foreach

foreach
	select no_documento, 
		   vigencia_ini,
		   vigencia_fin,
		   no_unidad,
		   no_endoso,
		   desc_unidad,
		   cod_contrato,
		   desc_contrato,
		   vig_ini_contr,
		   vig_fin_contr
	  into _no_documento,
		   _vig_ini,
		   _vig_fin,
		   _no_unidad,
		   _no_endoso,
		   _desc_unidad,
		   _cod_contrato,
		   _desc_contrato,
		   _vig_ini_contr,
		   _vig_fin_contr
	  from tmp_endosos
	 order by no_documento,no_endoso,no_unidad
	  
	return _no_documento,   		  --1_documento
		   _vig_ini,				  --2_vig_ini
		   _vig_fin,				  --3_vig_fin
		   _no_unidad,				  --4_no_unidad
		   _no_endoso,				  --5_no_endoso
		   _desc_unidad,			  --6_asegurado
		   _cod_contrato,			  --8_cod_contrato
		   _desc_contrato,			  --9_desc_contrato
		   _vig_ini_contr,			  --10_vig_ini_contr
		   _vig_fin_contr			  --11_vig_fin_contr
		   with resume;
end foreach

drop table tmp_endosos; 
end

end procedure