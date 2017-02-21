create or replace
type GEC_NO_DUP_STRCAT_TYPE as object (   
    cat_string varchar2(5000),    
    max_len    number ,   
    too_long   number ,    
    static function ODCIAggregateInitialize(cs_ctx In Out GEC_NO_DUP_STRCAT_TYPE) return number,    
    member function ODCIAggregateIterate(self In Out GEC_NO_DUP_STRCAT_TYPE,value in varchar2) return number,    
    member function ODCIAggregateMerge(self In Out GEC_NO_DUP_STRCAT_TYPE,ctx2 In Out GEC_NO_DUP_STRCAT_TYPE) return number,    
    member function ODCIAggregateTerminate(self In Out GEC_NO_DUP_STRCAT_TYPE,returnValue Out varchar2,flags in number) return number    
);
/
create or replace
type body GEC_NO_DUP_STRCAT_TYPE is  
  static function ODCIAggregateInitialize(cs_ctx IN OUT GEC_NO_DUP_STRCAT_TYPE) return number    
  is    
  begin    
      cs_ctx := GEC_NO_DUP_STRCAT_TYPE( cat_string => null, max_len => 4000, too_long => 0 );    
      return ODCIConst.Success;    
  end;    
  
  member function ODCIAggregateIterate(self IN OUT GEC_NO_DUP_STRCAT_TYPE,    
                                       value IN varchar2 )    
  return number    
  is    
  begin    
      if ( self.cat_string is null ) or    
         ( self.too_long < 1 and  
           instr(self.cat_string||',' , ','||value||',') < 1 )  then            
         if length(self.cat_string) + length(value) > self.max_len then  
            self.too_long := 1;   
            return ODCIConst.Success;    
         end if;                        
         self.cat_string := self.cat_string || ','|| value;   
      end if;       
         
      return ODCIConst.Success;    
  end;    
  
  member function ODCIAggregateTerminate(self IN Out GEC_NO_DUP_STRCAT_TYPE,    
                                         returnValue OUT varchar2,    
                                         flags IN number)    
  return number    
  is    
  begin    
      returnValue := substr(self.cat_string,2);    
      if self.too_long > 0 then    
         returnValue := substr(returnValue,1,self.max_len-3)||'...';   
      end if;   
         
      return ODCIConst.Success;    
  end;    
  
  member function ODCIAggregateMerge(self IN OUT GEC_NO_DUP_STRCAT_TYPE,    
                                     ctx2 IN Out GEC_NO_DUP_STRCAT_TYPE)    
  return number    
  is    
  begin    
      self.cat_string := self.cat_string || ',' || ctx2.cat_string;    
      return ODCIConst.Success;    
  end;    
end;   
/