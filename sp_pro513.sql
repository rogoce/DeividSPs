-- Polizas con producto nuevos y con recargo

-- Creado    : 12/09/2011 - Autor: Amado Perez

--drop procedure sp_pro513;

create procedure sp_pro513(a_fecha1 date, a_fecha2 date)
 returning char(20),
		   varchar(100),
		   date,
		   dec(5,2);
		   

define _no_documento    char(20);
define _nombre_cliente  varchar(100);
define _fecha_aniv      date;
define _porc_recargo	dec(5,2);


SET ISOLATION TO DIRTY READ;
foreach
  SELECT emicartasal.no_documento,   
         emicartasal.nombre_cliente,   
         emicartasal.fecha_aniv,   
         emiunire.porc_recargo
    INTO _no_documento,  
    	 _nombre_cliente,
    	 _fecha_aniv,    
    	 _porc_recargo	
    FROM emicartasal,   
         emipomae,   
         emipouni,   
         emiunire,   
         emidepen  
   WHERE ( emicartasal.no_documento = emipomae.no_documento ) and  
         ( emipouni.no_poliza = emipomae.no_poliza ) and  
         ( emiunire.no_poliza = emipouni.no_poliza ) and  
         ( emiunire.no_unidad = emipouni.no_unidad ) and  
         ( emidepen.no_poliza = emipouni.no_poliza ) and  
         ( emidepen.no_unidad = emipouni.no_unidad ) and 
         ( emiunire.porc_recargo > 0.00 ) and
         ( emicartasal.fecha_aniv >= a_fecha1 ) and
         ( emicartasal.fecha_aniv <= a_fecha2 )  
GROUP BY emicartasal.no_documento,   
         emicartasal.nombre_cliente,   
         emicartasal.fecha_aniv,   
         emiunire.porc_recargo   

	return _no_documento,  
		   _nombre_cliente,
		   _fecha_aniv,    
		   _porc_recargo	
		   with resume;

end foreach
end procedure
