-- Pool de logistica para cancelacion - estados impresion 1 - 2 - 3   
-- Creado : 16/2/2016 - Autor: Henry Giron.  
-- execute procedure sp_log006("I")  
-- drop procedure pr1009  

drop procedure sp_log006;  
create procedure "informix".sp_log006(a_estatus char(1) default "I") 
              returning char(15), 
						char(55),  
						char(15), 
						date, 
						float, 
						int, 
						char(15),  
						date,  
						char(1), --estatus
						int;     --cnt_acreedor 

define _no_aviso        char(15); 
define _nombre_ramo     char(55); 
define _user_proceso    char(15); 
define _fecha_proceso   date; 
define _sum_saldo       float; 
define _count_no_poliza int; 
define _user_imprimir_log char(15); 
define _date_imprimir_log date; 
define _estatus	 char(1);
--define _cod_avican     char(15);
define _total int; 
define _no_documento   char(20);
define _cnt_estatus int; 
define _cnt_color int; 
define _cnt_acreedor int;

set isolation to dirty read;  	 

let _count_no_poliza = 0;
let _user_imprimir_log = null;
let _date_imprimir_log = null;
let _fecha_proceso = null;
let _user_proceso = null;
let _sum_saldo = 0;

foreach  
    select d.no_aviso, a.nombre, count(d.no_poliza)
      into _no_aviso,_nombre_ramo, _total
	  from avicanpar a, avisocanc d
     where a.cod_avican = d.no_aviso
     group by d.no_aviso, a.nombre
	 order by 1,2 
 
	 select count(*)
	   into _cnt_estatus
	   from avisocanc
	  where estatus not in ('Y','I','W')
		and no_aviso = (_no_aviso);
 
     if _cnt_estatus is null then
	    let _cnt_estatus = 0;
    end if

     if _cnt_estatus <> 0 then
	    continue foreach;
    end if

	foreach
		select user_proceso, 
			   fecha_proceso,
			   count(distinct no_poliza)	
		  into _user_proceso,
			   _fecha_proceso,			 
			   _count_no_poliza			   
		  from avisocanc 
		 where estatus in ('I')
		   and no_aviso = (_no_aviso)
      group by user_proceso,
			   fecha_proceso			   
		  exit foreach;
	 end foreach
	 
	      if _count_no_poliza is null then
	         let _count_no_poliza = 0;
         end if 
		 
		 if _count_no_poliza = 0 then
			continue foreach;
		end if		 
	 
	 	 --if _total = _count_no_poliza then	

		select count(*)
		  into _cnt_color
		  from avisocanc
		 where decode(imprimir_log,null,0,imprimir_log) in (1,2)
		   and estatus in ('I')
		   and no_aviso = (_no_aviso);

		if _cnt_color is null then
		   let _cnt_color = 0;
	   end if

		if _cnt_color <> 0 then
			let _estatus = "1";
		else
			select count(*)
			  into _cnt_color
			  from avisocanc
			 where decode(imprimir_log,null,0,imprimir_log) in (0)
			   and estatus in ('I')
			   and no_aviso = (_no_aviso);

			if _cnt_color is null then
				let _cnt_color = 0;
			end if
			
			if _cnt_color = _count_no_poliza then
				let _estatus = "0";
			else 
				select count(*) 
				  into _cnt_color 
				  from avisocanc 
				 where decode(imprimir_log,null,0,imprimir_log) in (3) 
				   and estatus in ('I') 
				   and no_aviso = (_no_aviso);  

				if _cnt_color is null then
					let _cnt_color = 0;
				end if			
				
				if _cnt_color = _count_no_poliza then			
						let _estatus = "3";
					else
						let _estatus = "1";
				end if
			end if
			
		end if 
	
	    select sum(saldo) 	
		  into _sum_saldo
		  from avisocanc 
		 where estatus in ('I')
		   and no_aviso = (_no_aviso);	
		   
		if _sum_saldo is null then
		   let _sum_saldo = 0;
	   end if
	   
	  let _cnt_acreedor = 0; 
	select count(*)	
	  into _cnt_acreedor  
	  from avisocanc 
	 where estatus in ('I') and cancela = "0" 
       and trim(cod_acreedor) <> ""
	   and no_aviso = (_no_aviso);
	   
		if _cnt_acreedor is null then
		   let _cnt_acreedor = 0;
	   end if	   

	return _no_aviso,
		   _nombre_ramo,
		   _user_proceso,
		   _fecha_proceso,
		   _sum_saldo,
		   _count_no_poliza,
		   _user_imprimir_log,
		   _date_imprimir_log,           
		   _estatus,
           _cnt_acreedor		   
		with resume;
		
	--end if		
	


end foreach

 
end procedure

