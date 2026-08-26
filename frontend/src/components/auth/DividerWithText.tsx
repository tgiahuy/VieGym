export const DividerWithText = ({ text }: { text: string }) => {
  return (
    <div className="relative flex items-center justify-center my-6">
      <div className="absolute inset-0 flex items-center">
        <div className="w-full border-t border-border" />
      </div>
      <span className="relative px-2 text-xs uppercase bg-background text-muted-foreground">
        {text}
      </span>
    </div>
  );
};