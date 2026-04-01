-- Procedure que actualiza estado de impresion de aviso de cancelación. 
-- Creado    : 26/2/2016 - Autor: Henry Girón. 
-- SIS v.2.0 - DEIVID, S.A. 
-- Set debug file to 'sp_log010.trc'; 

-- trace on ; 

Drop procedure sp_log011_ns2;  
CREATE procedure "informix".sp_log011_ns2(a_no_aviso varchar(255) default "*")  
   RETURNING CHAR(20),  -- poliza  
             char(100), -- cliente  
			 char(50),  -- corredor  
			 char(50),  -- acreedor 
			 date,      -- fecha_aviso 
			 date,      -- date_imp_aviso_log 
             char(15),	-- user_imp_aviso_log 
			 char(10),  -- no_aviso 
			 varchar(255),  -- filtro
			 char(1),      -- enviado correo o impresion
			 char(10),     -- no_poliza
             smallint;     -- renglon			 
			 
BEGIN 

    define _no_documento       char(20);  
    define _name_corredor  	   char(50); 
    define _name_cliente       char(100); 
	define _name_acreedor	   char(50); 
	define _fecha_aviso        date; 
    define _user_imp_aviso_log char(15); 
    define _date_imp_aviso_log date; 
	define _no_aviso           char(10);
    define v_filtros           varchar(255); 
	define _tipo	           char(1); 
	define _no_poliza          char(10);
	define _cod_ramo           char(3); 
    define _correo	           char(1);  	
	define _renglon            smallint;
	
	define _acreedor_tmp	   char(50);
	define _poliza_tmp         char(10);		
	define _cantidad           integer;
	define _existe             integer;

drop table if exists acreedor_tmp;
drop table if exists tmp_codigos;

	SET ISOLATION TO DIRTY READ; 
	LET v_filtros     = "";	
	
	--set debug file to "sp_log011_ns1.trc"; 
	--trace on;		
	
    let a_no_aviso = '01644,01652,01655,01656,01657,01659,01661,01671,01679,01681,01682,01688,01692,01696,01700,01706,01710,01714,01718,01723,01724,01728,01730,01733,01734,01737;'  
			
	LET v_filtros = TRIM(v_filtros) ||" No.Avisos: "||TRIM(a_no_aviso);
	LET _tipo = sp_sis04(a_no_aviso); -- Separa los valores del String	
	
	select n.nombre nombre,a.no_poliza poliza
  from  emipoacr e, emiacre n, avisocanc a
where a.no_aviso IN (SELECT codigo FROM tmp_codigos )      
      -- and (( a.estatus in ('I')  and a.cancela = "0" and a.imp_aviso_log = '3' )  -- Correccion ya que salian incluso sin haber sido impreso 4/8/16 Henry
	   and ( a.estatus in ('X','M')  and a.cancela = "0"  and a.date_imp_aviso_log is null) --)	   -- Correccion ya que salian incluso sin haber sido impreso 10/01/2020 Henry
	   and ( a.user_marcar = 'DEIVID')
       and ( trim(a.cod_acreedor) <> "" )
	   --and a.saldo > 0    
       and e.cod_acreedor = n.cod_acreedor
     and e.no_poliza = a.no_poliza
	 --and trim(a.no_aviso)||"*"||a.renglon  IN (SELECT trim(no_aviso)||"*"||renglon FROM arreglo1 ) 	 
group by n.nombre,a.no_poliza
into temp acreedor_tmp; 		


foreach
	select distinct a.nombre_acreedor nombre,a.no_poliza poliza
	  into _acreedor_tmp, _poliza_tmp
	  from avisocanc a, emipomae b
	 where a.no_aviso IN (SELECT codigo FROM tmp_codigos ) 
      -- and (( a.estatus in ('I')  and a.cancela = "0" and a.imp_aviso_log = '3' )  -- Correccion ya que salian incluso sin haber sido impreso 4/8/16 Henry
	   and ( a.estatus in ('X','M')  and a.cancela = "0"  and a.date_imp_aviso_log is null) --)	   -- Correccion ya que salian incluso sin haber sido impreso 10/01/2020 Henry
	   and ( a.user_marcar = 'DEIVID')
       and ( trim(a.cod_acreedor) <> "" )
	   --and a.saldo > 0
      -- and a.imp_aviso_log = '3'
	   and a.no_poliza = b.no_poliza
	  -- and trim(a.no_aviso)||"*"||a.renglon  IN (SELECT trim(no_aviso)||"*"||renglon FROM arreglo1 ) 
	   and b.leasing = 1
	   
	   select count(*)
	     into _cantidad
	     from acreedor_tmp
	    where trim(nombre) = trim(_acreedor_tmp)
	      and trim(poliza) = trim(_poliza_tmp);
		  
		if _cantidad is null then
			let _cantidad = 0;
		end if		
		  
		  if _cantidad = 0 then	   
			   insert into acreedor_tmp(nombre,poliza)
			   values (_acreedor_tmp, _poliza_tmp);
		   end if
end foreach



FOREACH 
	select a.no_documento, 
	       a.nombre_cliente, 
           a.nombre_agente, 
           t.nombre, --a.nombre_acreedor, 
           a.fecha_proceso, 
           a.date_imp_aviso_log, 
		   a.user_imp_aviso_log,
		   a.no_aviso, a.no_poliza, a.clase, a.cod_ramo, a.renglon
	  into _no_documento, 
           _name_cliente, 
           _name_corredor, 
		   _name_acreedor, 
		   _fecha_aviso, 
		   _date_imp_aviso_log, 
           _user_imp_aviso_log,
           _no_aviso,_no_poliza	, _correo, _cod_ramo, _renglon	   
	  from avisocanc a, acreedor_tmp t 
	 where no_aviso IN (SELECT codigo FROM tmp_codigos ) 
      -- and (( a.estatus in ('I')  and a.cancela = "0" and a.imp_aviso_log = '3' )  -- Correccion ya que salian incluso sin haber sido impreso 4/8/16 Henry
	   and ( a.estatus in ('X','M')  and a.cancela = "0"  and a.date_imp_aviso_log is null) --)	   -- Correccion ya que salian incluso sin haber sido impreso 10/01/2020 Henry
	   and ( a.user_marcar = 'DEIVID')
       and ( trim(cod_acreedor) <> "" )
       and a.no_poliza = t.poliza	   
	 --  and trim(a.no_aviso)||"*"||a.renglon  IN (SELECT trim(no_aviso)||"*"||renglon FROM arreglo1 )       
	   order by a.nombre_acreedor,a.nombre_cliente,a.no_aviso 
	   
		{if _correo in ('1') then  --HG:17/05/2019, ASTANZIO CORREO del CESE
			if _cod_ramo not in ("002","020") then
				let _correo = '0';
			end if
		end if	}   
		
		let _existe = 0;
		select count(*) 
		  into _existe
		  from arreglo2 -- 101 polizas impresas 
		  where trim(no_documento) = trim(_no_documento);
		  
		if _existe is null then
			let _existe = 0;
		end if			  
		  
		  if _existe <> 0 then	  
		  continue foreach;
         end if		   
	   

		  RETURN _no_documento, 
				 _name_cliente, 
				 _name_corredor, 
				 _name_acreedor, 
				 _fecha_aviso, 
				 _date_imp_aviso_log, 
				 _user_imp_aviso_log, 
				 _no_aviso,
                 v_filtros,
                 _correo,
                 _no_poliza,
                 _renglon				 
				 WITH RESUME; 


end foreach
--drop table acreedor_tmp;
--DROP TABLE tmp_codigos;
END

END PROCEDURE;
